from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import (
    CoBuyParticipant,
    CoBuyPool,
    Dispute,
    Listing,
    Order,
    OrderReport,
    OrderReview,
    Profile,
    SellerReport,
    Shop,
)
from ..utils.images import save_image_as_webp
from .notifications import NotificationTarget, push_notification

router = APIRouter(prefix="/orders", tags=["orders"])

# Mirrors the frontend's `_kMaxPhotos` (rate_review_sheet.dart).
_MAX_REVIEW_PHOTOS = 6

# Escrow status state machine (15.1). Only the transitions reachable from
# the endpoints below are wired up today — `disputed`/`refunded` are real
# states an order can be in, but nothing can drive an order into them yet
# (that's Phase 15.4/15.5's dispute and refund endpoints).
STATUS_PENDING_PAYMENT = "pending_payment"
STATUS_HELD = "held"
STATUS_RELEASED = "released"
STATUS_DISPUTED = "disputed"
STATUS_REFUNDED = "refunded"
STATUS_CANCELLED = "cancelled"

_VALID_TRANSITIONS: dict[str, set[str]] = {
    STATUS_PENDING_PAYMENT: {STATUS_HELD, STATUS_CANCELLED},
    STATUS_HELD: {STATUS_RELEASED, STATUS_DISPUTED},
    STATUS_DISPUTED: {STATUS_RELEASED, STATUS_REFUNDED},
    STATUS_RELEASED: set(),
    STATUS_REFUNDED: set(),
    STATUS_CANCELLED: set(),
}

# After proof of delivery the buyer has this long to report a problem; when
# it runs out with nothing reported, the funds auto-release to the seller.
# Mocked down to 15s for demos — the app still shows it as a 3-day window,
# scaled (see `kReviewWindow`/`kShownReviewWindow` in order.dart).
REVIEW_WINDOW = timedelta(seconds=15)

# Mock courier: there's no real courier webhook, so a shipped parcel walks
# through 4 tracking steps (picked up → in transit → out for delivery →
# delivered), one every 3 seconds, and counts as delivered 12s after
# `shipped_at` — which starts the REVIEW_WINDOW timer. Mirrored by the
# app's `kMockDeliveryStep` (orders/models/order.dart).
MOCK_DELIVERY_STEP = timedelta(seconds=3)
MOCK_DELIVERY_STEPS = 4
MOCK_DELIVERY_DURATION = MOCK_DELIVERY_STEP * MOCK_DELIVERY_STEPS

# The buyer's escrow fee, charged at checkout on items + shipping — same rate
# as the checkout screen's `kEscrowFeeRate`.
ESCROW_FEE_RATE = 0.04

# The platform's cut, taken when funds are released to the seller — same
# rate as the seller app's earnings screen (`kSellerPlatformFeeRate`).
PLATFORM_FEE_RATE = 0.04

# Reduced rate for shops an admin granted the "Top Seller" badge (see
# `is_best_seller`), applied to every order released while they hold it.
TOP_SELLER_FEE_RATE = 0.03

# "Power Seller" badge: more than this many confirmed orders in a calendar
# month. Badge only — it doesn't change the fee.
HIGH_VOLUME_ORDERS = 40

# "Best Seller" badge: awarded once a shop has stayed on the platform for
# at least this long, regardless of order volume.
BEST_SELLER_TENURE_DAYS = 365

# Where sellers can withdraw released earnings.
PAYOUT_BANKS = {"ABA", "Wing"}


def _aware(dt: datetime) -> datetime:
    """SQLite (test harness) returns tz-naive datetimes for tz-aware columns."""
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=timezone.utc)


def _month_start(dt: datetime) -> datetime:
    return dt.replace(day=1, hour=0, minute=0, second=0, microsecond=0)


def confirmed_orders_in_month(db: Session, seller_id: str, month_of: datetime) -> int:
    """Orders the seller confirmed during the calendar month of `month_of`
    (UTC), leaving out ones that never got paid, were cancelled or refunded."""
    start = _month_start(month_of)
    end = (start + timedelta(days=32)).replace(day=1)
    return (
        db.query(Order)
        .filter(
            Order.seller_id == seller_id,
            Order.seller_confirmed_at.is_not(None),
            Order.seller_confirmed_at >= start,
            Order.seller_confirmed_at < end,
            Order.status.notin_(
                [STATUS_PENDING_PAYMENT, STATUS_CANCELLED, STATUS_REFUNDED]
            ),
        )
        .count()
    )


def fee_rate_for(db: Session, seller_id: str) -> float:
    """The platform's cut for this seller right now: 3% with the admin-granted
    "Top Seller" badge, otherwise the standard 4%."""
    shop = db.get(Shop, seller_id)
    if shop is not None and is_best_seller(shop, datetime.now(timezone.utc)):
        return TOP_SELLER_FEE_RATE
    return PLATFORM_FEE_RATE


def is_high_volume_seller(db: Session, seller_id: str, now: datetime) -> bool:
    """Whether the seller earns the "Power Seller" badge: they passed the
    high-volume threshold this month or last, so the badge doesn't vanish on
    the 1st."""
    if confirmed_orders_in_month(db, seller_id, now) > HIGH_VOLUME_ORDERS:
        return True
    last_month = _month_start(now) - timedelta(days=1)
    return confirmed_orders_in_month(db, seller_id, last_month) > HIGH_VOLUME_ORDERS


def is_best_seller(shop: Shop, now: datetime) -> bool:
    """Whether the shop shows the "Top Seller" badge. Admin-granted only:
    `best_seller_override` must be explicitly true (null/false = no badge)."""
    return shop.best_seller_override is True


def release_funds(
    db: Session,
    order: Order,
    now: datetime,
    *,
    auto: bool = False,
    fee_rate: float = PLATFORM_FEE_RATE,
) -> None:
    """Moves a held/disputed order to `released` and records the fee cut.
    Every release path (buyer confirm, auto-release, admin decision) goes
    through here so the fee is always taken the same way. The commission is
    on the goods only; the shipping the buyer paid goes to the seller, who
    shipped it."""
    _transition(order, STATUS_RELEASED)
    order.released_at = now
    order.platform_fee = round(order.total_amount * fee_rate, 2)
    order.seller_amount = round(
        order.total_amount - order.platform_fee + (order.shipping_fee or 0), 2
    )
    participant = _co_buy_participant(db, order)
    if participant is not None:
        participant.status = "released"
        participant.released_at = now
    order.auto_released = auto
    order.review_deadline_at = None
    order.review_remaining_seconds = None


# After an admin cancels an order over a courier problem (lost/damaged), the
# buyer's money is held this long before it goes back, so a courier claim or
# a wrongly-reported case can still be sorted out.
COURIER_REFUND_DELAY = timedelta(days=3)


def escrow_fee_paid(order: Order) -> float:
    """The 4% escrow fee the buyer paid on this order — recorded at payment,
    or derived for orders paid before it was."""
    if order.escrow_fee:
        return order.escrow_fee
    return round((order.total_amount + (order.shipping_fee or 0)) * ESCROW_FEE_RATE, 2)


def refund_amount_for(order: Order, *, buyer_fault: bool) -> float:
    """What goes back to the buyer. Not their fault (wrong/fake/damaged
    goods, never shipped, lost by the courier, co-buy deal cancelled):
    everything they paid. Their own choice (changed their mind): the goods,
    plus shipping if it never shipped — but the 4% escrow fee is kept."""
    shipping = order.shipping_fee or 0
    if buyer_fault and order.shipped_at is not None:
        shipping = 0
    fee = 0 if buyer_fault else escrow_fee_paid(order)
    return round(order.total_amount + shipping + fee, 2)


def refund_order(
    db: Session, order: Order, now: datetime, *, buyer_fault: bool = False
) -> None:
    """Returns a held/disputed order's money to the buyer and closes any
    dispute open on it. Records the amount owed back for the admin's refund
    queue — see `refund_amount_for` for what's kept when the buyer's at fault."""
    if order.status == STATUS_HELD:
        _transition(order, STATUS_DISPUTED)
    _transition(order, STATUS_REFUNDED)
    order.refunded_at = now
    order.refund_amount = refund_amount_for(order, buyer_fault=buyer_fault)
    order.review_deadline_at = None
    order.review_remaining_seconds = None
    if order.stock_taken and order.shipped_at is None:
        # The goods never left the seller, so they're back on sale.
        listing = db.get(Listing, order.listing_id)
        if listing is not None:
            listing.stock_qty += order.quantity
        order.stock_taken = False
    participant = _co_buy_participant(db, order)
    if participant is not None and participant.status != "refunded":
        # Frees their quantity in the deal for other buyers.
        participant.status = "refunded"
        participant.refunded_at = now
    dispute = db.query(Dispute).filter(Dispute.order_id == order.id).one_or_none()
    if dispute is not None and dispute.status != "resolved":
        dispute.status = "resolved"
        dispute.resolution = "refund"
        dispute.fault = "courier"
        dispute.resolved_at = now


def _check_sample_eligible(db: Session, buyer_id: str) -> None:
    """One sample per buyer every 3 days (see routers/sample_orders.py)."""
    from .sample_orders import sample_eligibility

    eligible, eligible_at = sample_eligibility(db, buyer_id)
    if not eligible:
        raise HTTPException(
            status_code=409,
            detail={
                "message": "Only one sample order is allowed every 3 days",
                "eligible_at": eligible_at.isoformat() if eligible_at else None,
            },
        )


def _co_buy_participant(db: Session, order: Order) -> CoBuyParticipant | None:
    if order.co_buy_participant_id is None:
        return None
    return db.get(CoBuyParticipant, order.co_buy_participant_id)


def allocate_escrow_fee(orders: list[Order], total_fee: float) -> None:
    """Splits one payment's 4% escrow fee across its orders by what each
    paid (goods + shipping share), the last taking the rounding remainder."""
    left = round(total_fee, 2)
    for i, order in enumerate(orders):
        if i == len(orders) - 1:
            share = left
        else:
            share = round(
                (order.total_amount + (order.shipping_fee or 0)) * ESCROW_FEE_RATE, 2
            )
        order.escrow_fee = share
        left = round(left - share, 2)


def allocate_shipping(orders: list[Order], shipping: float) -> None:
    """Splits one checkout's shipping across its orders in proportion to
    their value (evenly if they're all free), the last order taking the
    rounding remainder so the shares add up to exactly what was paid."""
    if not orders:
        return
    total = sum(o.total_amount for o in orders)
    left = round(shipping, 2)
    for i, order in enumerate(orders):
        if i == len(orders) - 1:
            share = left
        elif total > 0:
            share = round(shipping * order.total_amount / total, 2)
        else:
            share = round(shipping / len(orders), 2)
        order.shipping_fee = share
        left = round(left - share, 2)


def cancel_unpaid_order(order: Order, now: datetime) -> None:
    """Cancels an order the buyer never paid for — nothing to refund."""
    _transition(order, STATUS_CANCELLED)
    order.cancelled_at = now


def _stock_needed(orders: list[Order]) -> dict[str, int]:
    """Units each listing must have on hand for these orders. Co-buy joins
    draw on their deal's target instead (see co_buy.py `remaining_qty`)."""
    needed: dict[str, int] = {}
    for order in orders:
        if order.co_buy_participant_id is None:
            needed[order.listing_id] = needed.get(order.listing_id, 0) + order.quantity
    return needed


def _out_of_stock_detail(listing: Listing) -> str:
    if listing.stock_qty <= 0:
        return f"{listing.product_name} is out of stock"
    return f"Only {listing.stock_qty} of {listing.product_name} left in stock"


def check_stock(db: Session, orders: list[Order]) -> None:
    """Refuses a checkout asking for more than a listing has left."""
    for listing_id, qty in _stock_needed(orders).items():
        listing = db.get(Listing, listing_id)
        if listing is not None and qty > listing.stock_qty:
            raise HTTPException(status_code=409, detail=_out_of_stock_detail(listing))


def take_stock(db: Session, orders: list[Order]) -> bool:
    """Takes newly paid orders' units off their listings' stock. All or
    nothing: returns False, changing nothing, when a listing no longer has
    enough (another buyer's payment landed first). Locks the listing rows
    until the caller commits."""
    needed = _stock_needed(orders)
    if not needed:
        return True
    listings = {
        listing.id: listing
        for listing in db.query(Listing)
        .filter(Listing.id.in_(needed))
        .order_by(Listing.id)
        .with_for_update()
        .populate_existing()
        .all()
    }
    if any(
        qty > listings[listing_id].stock_qty
        for listing_id, qty in needed.items()
        if listing_id in listings
    ):
        return False
    for listing_id, qty in needed.items():
        if listing_id in listings:
            listings[listing_id].stock_qty -= qty
    for order in orders:
        if order.co_buy_participant_id is None:
            order.stock_taken = True
    return True


def freeze_order(order: Order, now: datetime) -> None:
    """Moves a held order to `disputed` and stops its review timer so it
    can't auto-release while a refund is pending."""
    if order.status != STATUS_HELD:
        return
    _transition(order, STATUS_DISPUTED)
    if order.review_deadline_at is not None:
        remaining = _aware(order.review_deadline_at) - now
        order.review_remaining_seconds = max(0, int(remaining.total_seconds()))
        order.review_deadline_at = None


def unfreeze_order(order: Order, now: datetime) -> None:
    """Undoes `freeze_order` once the report behind it is dismissed: the
    order goes back to `held` and its review timer picks up where it left
    off. Bypasses `_transition` on purpose — `disputed` → `held` is only
    valid here, never for a buyer's dispute."""
    if order.status != STATUS_DISPUTED:
        return
    order.status = STATUS_HELD
    if order.review_remaining_seconds is not None:
        order.review_deadline_at = now + timedelta(
            seconds=order.review_remaining_seconds
        )
        order.review_remaining_seconds = None


def _refund_due_reports(db: Session, now: datetime) -> None:
    reports = (
        db.query(SellerReport)
        .filter(
            SellerReport.status == "refund_pending",
            SellerReport.refund_due_at.is_not(None),
            SellerReport.refund_due_at <= now,
        )
        .all()
    )
    for report in reports:
        order = db.get(Order, report.order_id)
        if order is not None and order.status in (STATUS_HELD, STATUS_DISPUTED):
            refund_order(db, order, now)
        report.status = "resolved"
        report.resolution = "refunded"
    if reports:
        db.commit()


def _deliver_due_shipments(db: Session, now: datetime) -> None:
    """Marks shipped orders delivered once the mock courier's
    MOCK_DELIVERY_DURATION has passed, starting their review timer from the
    moment of delivery. Only `held` orders — one the buyer reported while it
    was in transit is `disputed` and stays undelivered."""
    shipped = (
        db.query(Order)
        .filter(
            Order.status == STATUS_HELD,
            Order.shipped_at.is_not(None),
            Order.delivered_at.is_(None),
            Order.shipped_at <= now - MOCK_DELIVERY_DURATION,
        )
        .all()
    )
    if not shipped:
        return
    for order in shipped:
        delivered_at = _aware(order.shipped_at) + MOCK_DELIVERY_DURATION
        order.delivered_at = delivered_at
        order.review_deadline_at = delivered_at + REVIEW_WINDOW
    db.commit()
    for order in shipped:
        _notify_buyer(
            db,
            order,
            "Your order was delivered",
            f"{order.product_name} arrived. Check it and confirm, or report a problem before the review window ends.",
            route="deliveryTracking",
        )


def auto_release_due_orders(db: Session) -> None:
    """Delivers mock shipments that have arrived, releases every held order
    whose review timer has run out, and refunds orders whose admin-scheduled
    refund is due. There's no background scheduler, so this runs lazily
    whenever orders are read."""
    now = datetime.now(timezone.utc)
    _deliver_due_shipments(db, now)
    _refund_due_reports(db, now)
    due = (
        db.query(Order)
        .filter(
            Order.status == STATUS_HELD,
            Order.review_deadline_at.is_not(None),
            Order.review_deadline_at <= now,
        )
        .all()
    )
    if not due:
        return
    for order in due:
        release_funds(
            db, order, now, auto=True, fee_rate=fee_rate_for(db, order.seller_id)
        )
    db.commit()
    for order in due:
        notify_order_released(db, order)


def seller_amount_for(order: Order) -> float:
    """What the seller is owed — recorded at release, or derived for orders
    released before fees were recorded."""
    if order.seller_amount is not None:
        return order.seller_amount
    return round(
        order.total_amount * (1 - PLATFORM_FEE_RATE) + (order.shipping_fee or 0), 2
    )


def _notify_buyer(
    db: Session, order: Order, title: str, body: str, route: str = "orderDetail"
) -> None:
    push_notification(
        db,
        order.buyer_id,
        "order",
        title,
        body,
        NotificationTarget(route=route, params={"id": order.id}),
    )


def notify_order_released(db: Session, order: Order) -> None:
    """Funds went to the seller: tell them, and ask the buyer to rate."""
    push_notification(
        db,
        order.seller_id,
        "escrow",
        "Funds released from escrow",
        f"Payment for {order.product_name} was released to you.",
        NotificationTarget(route="sellerOrderDetail", params={"id": order.id}),
    )
    _notify_buyer(
        db,
        order,
        "How was your order?",
        f"Rate the seller for {order.product_name} to help other buyers.",
    )


def _transition(order: Order, new_status: str) -> None:
    allowed = _VALID_TRANSITIONS.get(order.status, set())
    if new_status not in allowed:
        raise HTTPException(
            status_code=409,
            detail=f"Cannot move order from '{order.status}' to '{new_status}'",
        )
    order.status = new_status


def mark_order_paid(db: Session, order: Order, method: str, reference: str) -> None:
    """Moves a pending order into held escrow once ABA PayWay has confirmed
    its payment (routers/payments.py), and tells the seller. Commits."""
    _transition(order, STATUS_HELD)
    order.payment_method = method
    order.payment_reference = reference
    order.paid_at = datetime.now(timezone.utc)
    db.commit()
    push_notification(
        db,
        order.seller_id,
        "order",
        "New order received",
        f"{order.quantity} × {order.product_name} was paid and is held in escrow. Confirm and ship it.",
        NotificationTarget(route="sellerOrderDetail", params={"id": order.id}),
    )


def _get_participant_order(db: Session, order_id: str, user_id: str) -> Order:
    order = db.get(Order, order_id)
    if order is None or user_id not in (order.buyer_id, order.seller_id):
        # 404, not 403 — matches the ownership-hiding pattern used by
        # listings/chat so a non-participant can't confirm an order exists.
        raise HTTPException(status_code=404, detail="Order not found")
    return order


class OrderCreate(BaseModel):
    listing_id: str
    quantity: int
    shipping_name: str = ""
    shipping_address: str = ""
    shipping_phone: str = ""
    # One unit at the listing's sample price (full price, not wholesale).
    sample: bool = False


class OrderReviewOut(BaseModel):
    id: str
    order_id: str
    buyer_id: str
    rating: int
    comment: str
    photo_urls: list[str]
    created_at: datetime
    # Not columns on `order_reviews` — the reviewer's display name/avatar,
    # looked up the same way seller_name/seller_logo_url are on OrderOut, so
    # the seller sees who left the review.
    buyer_name: str | None = None
    buyer_avatar_url: str | None = None

    model_config = {"from_attributes": True}


class OrderOut(BaseModel):
    id: str
    buyer_id: str
    seller_id: str
    listing_id: str
    product_name: str
    unit_price: float
    quantity: int
    total_amount: float
    shipping_name: str
    shipping_address: str
    shipping_phone: str
    status: str
    payment_method: str | None
    payment_reference: str | None
    created_at: datetime
    updated_at: datetime
    paid_at: datetime | None
    seller_confirmed_at: datetime | None
    released_at: datetime | None
    release_requested_at: datetime | None
    cancelled_at: datetime | None
    refunded_at: datetime | None
    payout_requested_at: datetime | None
    payout_eta_at: datetime | None
    payout_bank_name: str | None
    payout_account_holder: str | None
    payout_account_number: str | None
    shipped_at: datetime | None
    courier: str | None
    tracking_number: str | None
    shipping_photo_url: str | None
    delivered_at: datetime | None
    delivery_proof_url: str | None
    review_deadline_at: datetime | None
    review_remaining_seconds: int | None
    platform_fee: float | None
    is_sample: bool = False
    # Shipping the buyer paid for this order; added to the seller's payout.
    shipping_fee: float = 0.0
    escrow_fee: float = 0.0
    # Set once refunded: what's owed back to the buyer.
    refund_amount: float | None = None
    # When the admin actually sent that refund (null while it's queued).
    refund_sent_at: datetime | None = None
    seller_amount: float | None
    auto_released: bool
    # Not a column on `escrow_orders` — the listing's own first photo,
    # looked up at response time so the order card can show the real
    # product instead of a generic box icon.
    image_url: str | None = None
    # Not a column either — same shop/profile lookup `_serialize_listing`
    # (listings.py) does, so order screens can show the real store name
    # and logo instead of nothing.
    seller_name: str | None = None
    seller_logo_url: str | None = None
    # The buyer's rating/review of this order, once they've left one —
    # `None` until then. Shown back on both the buyer's and the seller's
    # order detail screens.
    review: OrderReviewOut | None = None
    # Why a `disputed` order is on hold, so the buyer's screens can explain
    # it. `hold_source` is "buyer" (they reported a problem) or "delivery"
    # (an admin cancelled it over a courier problem). `refund_due_at` is only
    # set for "delivery", where the refund date is already scheduled.
    hold_source: str | None = None
    hold_reason: str | None = None
    hold_note: str | None = None
    refund_due_at: datetime | None = None

    model_config = {"from_attributes": True}


def _order_out(
    order: Order,
    image_url: str | None,
    seller_name: str | None,
    seller_logo_url: str | None,
    review: OrderReviewOut | None = None,
) -> OrderOut:
    return OrderOut.model_validate(order).model_copy(
        update={
            "image_url": image_url,
            "seller_name": seller_name,
            "seller_logo_url": seller_logo_url,
            "review": review,
        }
    )


def _seller_info(db: Session, seller_id: str) -> tuple[str, str | None]:
    shop = db.get(Shop, seller_id)
    profile = db.get(Profile, seller_id)
    name = (shop.shop_name if shop else "") or (profile.name if profile else "") or "Seller"
    logo_url = shop.logo_url if shop and shop.logo_url else None
    return name, logo_url


def _review_out(
    review: OrderReview | None,
    buyer_profile: Profile | None,
) -> OrderReviewOut | None:
    if review is None:
        return None
    return OrderReviewOut.model_validate(review).model_copy(
        update={
            "buyer_name": buyer_profile.name if buyer_profile else None,
            "buyer_avatar_url": buyer_profile.avatar_url
            if buyer_profile and buyer_profile.avatar_url
            else None,
        }
    )


def _attach_hold_info(db: Session, outs: list[OrderOut]) -> list[OrderOut]:
    disputed = [o for o in outs if o.status == STATUS_DISPUTED]
    if not disputed:
        return outs
    ids = [o.id for o in disputed]
    reports = {
        r.order_id: r
        for r in db.query(SellerReport)
        .filter(
            SellerReport.order_id.in_(ids),
            SellerReport.status.in_(("open", "refund_pending")),
        )
        .all()
    }
    disputes = {
        d.order_id: d for d in db.query(Dispute).filter(Dispute.order_id.in_(ids)).all()
    }
    for out in disputed:
        report = reports.get(out.id)
        dispute = disputes.get(out.id)
        if report is not None:
            out.hold_source = "delivery"
            out.hold_reason = report.reason
            out.hold_note = report.note or None
            out.refund_due_at = report.refund_due_at
        elif dispute is not None:
            out.hold_source = "buyer"
            out.hold_reason = dispute.reason
            out.hold_note = dispute.note or None
    return outs


def _order_out_single(db: Session, order: Order) -> OrderOut:
    listing = db.get(Listing, order.listing_id) or db.get(CoBuyPool, order.listing_id)
    image_url = listing.photo_urls[0] if listing and listing.photo_urls else None
    seller_name, seller_logo_url = _seller_info(db, order.seller_id)
    review_row = (
        db.query(OrderReview).filter(OrderReview.order_id == order.id).one_or_none()
    )
    buyer_profile = db.get(Profile, order.buyer_id) if review_row else None
    review = _review_out(review_row, buyer_profile)
    out = _order_out(order, image_url, seller_name, seller_logo_url, review)
    return _attach_hold_info(db, [out])[0]


def _order_out_many(db: Session, orders: list[Order]) -> list[OrderOut]:
    listing_ids = {order.listing_id for order in orders}
    if not listing_ids:
        return []
    listings = db.query(Listing).filter(Listing.id.in_(listing_ids)).all()
    image_by_listing = {
        listing.id: listing.photo_urls[0]
        for listing in listings
        if listing.photo_urls
    }
    # Co-buy orders point at their deal rather than a listing.
    for pool in db.query(CoBuyPool).filter(CoBuyPool.id.in_(listing_ids)).all():
        if pool.photo_urls:
            image_by_listing[pool.id] = pool.photo_urls[0]

    seller_ids = {order.seller_id for order in orders}
    shops = {
        shop.id: shop for shop in db.query(Shop).filter(Shop.id.in_(seller_ids)).all()
    }
    profiles = {
        profile.id: profile
        for profile in db.query(Profile).filter(Profile.id.in_(seller_ids)).all()
    }

    def seller_info(seller_id: str) -> tuple[str, str | None]:
        shop = shops.get(seller_id)
        profile = profiles.get(seller_id)
        name = (shop.shop_name if shop else "") or (profile.name if profile else "") or "Seller"
        logo_url = shop.logo_url if shop and shop.logo_url else None
        return name, logo_url

    order_ids = [order.id for order in orders]
    reviews_by_order = {
        review.order_id: review
        for review in db.query(OrderReview)
        .filter(OrderReview.order_id.in_(order_ids))
        .all()
    }
    reviewer_ids = {review.buyer_id for review in reviews_by_order.values()}
    reviewer_profiles = (
        {str(p.id): p for p in db.query(Profile).filter(Profile.id.in_(reviewer_ids)).all()}
        if reviewer_ids
        else {}
    )

    result = []
    for order in orders:
        seller_name, seller_logo_url = seller_info(order.seller_id)
        review_row = reviews_by_order.get(order.id)
        review = _review_out(
            review_row,
            reviewer_profiles.get(review_row.buyer_id) if review_row else None,
        )
        result.append(
            _order_out(
                order,
                image_by_listing.get(order.listing_id),
                seller_name,
                seller_logo_url,
                review,
            )
        )
    return _attach_hold_info(db, result)


_COBUY_ORDER_PREFIX = "cobuy-"
# Participant status -> the order status a buyer sees. A pending or approved
# leave both read as "cancelled".
_COBUY_STATUS_MAP = {
    "held": STATUS_HELD,
    "released": STATUS_RELEASED,
    "leave_requested": STATUS_CANCELLED,
    "refunded": STATUS_CANCELLED,
}


def _cobuy_order_out(
    db: Session, participant: CoBuyParticipant, pool: CoBuyPool
) -> OrderOut:
    seller_name, seller_logo_url = _seller_info(db, pool.seller_id)
    updated = (
        participant.refunded_at
        or participant.leave_requested_at
        or participant.paid_at
        or participant.joined_at
    )
    cancelled = participant.status in ("leave_requested", "refunded")
    return OrderOut(
        id=_COBUY_ORDER_PREFIX + participant.id,
        buyer_id=participant.buyer_id,
        seller_id=pool.seller_id,
        listing_id=pool.id,
        product_name=pool.product_name,
        unit_price=pool.price,
        quantity=participant.quantity,
        total_amount=round(pool.price * participant.quantity, 2),
        shipping_name="",
        shipping_address="",
        shipping_phone="",
        status=_COBUY_STATUS_MAP.get(participant.status, STATUS_HELD),
        payment_method=participant.payment_method,
        payment_reference=participant.payment_reference,
        created_at=participant.paid_at or participant.joined_at,
        updated_at=updated,
        paid_at=participant.paid_at,
        seller_confirmed_at=None,
        released_at=participant.released_at,
        release_requested_at=None,
        cancelled_at=(participant.refunded_at or participant.leave_requested_at)
        if cancelled
        else None,
        refunded_at=participant.refunded_at,
        payout_requested_at=None,
        payout_eta_at=None,
        payout_bank_name=None,
        payout_account_holder=None,
        payout_account_number=None,
        shipped_at=None,
        courier=None,
        tracking_number=None,
        shipping_photo_url=None,
        delivered_at=None,
        delivery_proof_url=None,
        review_deadline_at=None,
        review_remaining_seconds=None,
        platform_fee=None,
        seller_amount=None,
        auto_released=False,
        image_url=pool.photo_urls[0] if pool.photo_urls else None,
        seller_name=seller_name,
        seller_logo_url=seller_logo_url,
    )


def _my_cobuy_orders(db: Session, user_id: str) -> list[OrderOut]:
    """Synthetic order rows for co-buy joins paid before joins got a real
    escrow `Order` — joins that have one are listed through it instead."""
    linked = {
        pid
        for (pid,) in db.query(Order.co_buy_participant_id).filter(
            Order.buyer_id == user_id, Order.co_buy_participant_id.is_not(None)
        )
    }
    rows = (
        db.query(CoBuyParticipant, CoBuyPool)
        .join(CoBuyPool, CoBuyPool.id == CoBuyParticipant.pool_id)
        .filter(
            CoBuyParticipant.buyer_id == user_id,
            CoBuyParticipant.status.in_(tuple(_COBUY_STATUS_MAP)),
        )
        .all()
    )
    return [
        _cobuy_order_out(db, part, pool)
        for part, pool in rows
        if part.id not in linked
    ]


@router.get("/me", response_model=list[OrderOut])
def list_my_orders(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[OrderOut]:
    # Excludes orders where the user bought from their own store — those are
    # self-sales, not purchases from another store, so they only belong in
    # the seller's own order list (list_my_sales) to avoid confusing a seller
    # account into thinking a customer order is one of their own purchases.
    auto_release_due_orders(db)
    orders = (
        db.query(Order)
        .filter(Order.buyer_id == user.id, Order.seller_id != user.id)
        .order_by(Order.created_at.desc())
        .all()
    )
    outs = _order_out_many(db, orders) + _my_cobuy_orders(db, user.id)
    outs.sort(key=lambda o: o.created_at, reverse=True)
    return outs


@router.get("/me/selling", response_model=list[OrderOut])
def list_my_sales(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[OrderOut]:
    auto_release_due_orders(db)
    orders = (
        db.query(Order)
        .filter(Order.seller_id == user.id)
        .order_by(Order.created_at.desc())
        .all()
    )
    return _order_out_many(db, orders)


@router.get("/seller/{seller_id}/reviews", response_model=list[OrderReviewOut])
def list_seller_reviews(
    seller_id: str, db: Session = Depends(get_db)
) -> list[OrderReviewOut]:
    """Public: every buyer review left on this seller's orders, newest first
    — shown on the storefront's Reviews tab."""
    reviews = (
        db.query(OrderReview)
        .join(Order, Order.id == OrderReview.order_id)
        .filter(Order.seller_id == seller_id)
        .order_by(OrderReview.created_at.desc())
        .all()
    )
    buyer_ids = {r.buyer_id for r in reviews}
    profiles = (
        {str(p.id): p for p in db.query(Profile).filter(Profile.id.in_(buyer_ids)).all()}
        if buyer_ids
        else {}
    )
    return [_review_out(r, profiles.get(r.buyer_id)) for r in reviews]


@router.post("", response_model=OrderOut)
def create_order(
    payload: OrderCreate,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    if payload.quantity < 1:
        raise HTTPException(status_code=400, detail="Quantity must be at least 1")

    listing = db.get(Listing, payload.listing_id)
    if listing is None:
        raise HTTPException(status_code=404, detail="Listing not found")
    if listing.seller_id == user.id:
        raise HTTPException(
            status_code=400, detail="You can't buy your own listing"
        )

    if payload.sample:
        if not listing.sample_testing_enabled or listing.sample_price is None:
            raise HTTPException(
                status_code=400, detail="This listing does not offer sample testing"
            )
        _check_sample_eligible(db, user.id)
        unit_price, quantity = listing.sample_price, 1
        product_name = f"{listing.product_name} (Sample)"
    else:
        unit_price, quantity = listing.price, payload.quantity
        product_name = listing.product_name
    if quantity > listing.stock_qty:
        raise HTTPException(status_code=409, detail=_out_of_stock_detail(listing))

    order = Order(
        buyer_id=user.id,
        seller_id=listing.seller_id,
        listing_id=listing.id,
        product_name=product_name,
        unit_price=unit_price,
        quantity=quantity,
        total_amount=round(unit_price * quantity, 2),
        shipping_name=payload.shipping_name,
        shipping_address=payload.shipping_address,
        shipping_phone=payload.shipping_phone,
        is_sample=payload.sample,
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    seller_name, seller_logo_url = _seller_info(db, order.seller_id)
    return _order_out(
        order,
        listing.photo_urls[0] if listing.photo_urls else None,
        seller_name,
        seller_logo_url,
    )


@router.get("/{order_id}", response_model=OrderOut)
def get_order(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    auto_release_due_orders(db)
    if order_id.startswith(_COBUY_ORDER_PREFIX):
        part = db.get(CoBuyParticipant, order_id[len(_COBUY_ORDER_PREFIX):])
        pool = db.get(CoBuyPool, part.pool_id) if part else None
        if part is None or pool is None or part.buyer_id != user.id:
            raise HTTPException(status_code=404, detail="Order not found")
        return _cobuy_order_out(db, part, pool)
    order = _get_participant_order(db, order_id, user.id)
    return _order_out_single(db, order)


@router.post("/{order_id}/confirm", response_model=OrderOut)
def confirm_order(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    """Seller acknowledging a held order so the buyer can see it's being
    handled — doesn't change `status`, just timestamps the acknowledgement."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.seller_id:
        raise HTTPException(status_code=403, detail="Only the seller can confirm this order")
    if order.status != STATUS_HELD:
        raise HTTPException(
            status_code=409,
            detail=f"Order must be '{STATUS_HELD}' to confirm",
        )

    order.seller_confirmed_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(order)
    _notify_buyer(db, order, "Order confirmed", "The seller confirmed your order and is preparing it.")
    return _order_out_single(db, order)


def _save_fulfilment_photo(photo: UploadFile, folder: str, user_id: str) -> str:
    return save_image_as_webp(photo, folder, user_id)


@router.post("/{order_id}/ship", response_model=OrderOut)
def ship_order(
    order_id: str,
    courier: str = Form(...),
    tracking_number: str = Form(...),
    photo: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    """Seller handing the parcel to a courier: needs a photo of the packed
    parcel and the tracking number. The funds stay held."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.seller_id:
        raise HTTPException(status_code=403, detail="Only the seller can ship this order")
    if order.status != STATUS_HELD:
        raise HTTPException(
            status_code=409, detail=f"Order must be '{STATUS_HELD}' to ship"
        )
    participant = _co_buy_participant(db, order)
    if participant is not None and participant.status == "leave_requested":
        raise HTTPException(
            status_code=409,
            detail="The buyer asked to leave this co-buy deal — wait for the admin's decision",
        )
    if participant is not None:
        pool = db.get(CoBuyPool, participant.pool_id)
        if pool is not None and pool.status != "funded":
            raise HTTPException(
                status_code=409,
                detail="This co-buy deal hasn't reached its target yet — ship once it does",
            )
    if order.shipped_at is not None:
        raise HTTPException(status_code=409, detail="Order already shipped")
    courier = courier.strip()
    tracking_number = tracking_number.strip()
    if not courier or not tracking_number:
        raise HTTPException(status_code=422, detail="Courier and tracking number are required")

    now = datetime.now(timezone.utc)
    order.shipping_photo_url = _save_fulfilment_photo(
        photo, "shipping_photos", user.id
    )
    order.courier = courier
    order.tracking_number = tracking_number
    order.shipped_at = now
    if order.seller_confirmed_at is None:
        order.seller_confirmed_at = now
    db.commit()
    db.refresh(order)
    _notify_buyer(
        db,
        order,
        "Your order has shipped",
        f"{order.product_name} is on its way with {courier} (tracking {tracking_number}).",
        route="deliveryTracking",
    )
    return _order_out_single(db, order)


@router.post("/{order_id}/deliver", response_model=OrderOut)
def mark_delivered(
    order_id: str,
    photo: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    """Seller uploading proof of delivery (courier receipt / handover
    photo). This starts the buyer's review window: when the timer ends with
    no problem reported, the funds auto-release."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.seller_id:
        raise HTTPException(status_code=403, detail="Only the seller can mark this delivered")
    if order.status != STATUS_HELD or order.shipped_at is None:
        raise HTTPException(status_code=409, detail="Order must be shipped first")
    if order.delivered_at is not None:
        raise HTTPException(status_code=409, detail="Order already marked delivered")

    now = datetime.now(timezone.utc)
    order.delivery_proof_url = _save_fulfilment_photo(
        photo, "delivery_proofs", user.id
    )
    order.delivered_at = now
    order.review_deadline_at = now + REVIEW_WINDOW
    db.commit()
    db.refresh(order)
    _notify_buyer(
        db,
        order,
        "Your order was delivered",
        f"{order.product_name} arrived. Check it and confirm, or report a problem before the review window ends.",
    )
    return _order_out_single(db, order)


@router.post("/{order_id}/request-release", response_model=OrderOut)
def request_release(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    """Seller asking the admin to release the held funds — the admin
    approves it from the web panel (routers/admin.py)."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.seller_id:
        raise HTTPException(status_code=403, detail="Only the seller can request a release")
    if order.status != STATUS_HELD:
        raise HTTPException(
            status_code=409,
            detail=f"Order must be '{STATUS_HELD}' to request a release",
        )
    if order.release_requested_at is None:
        order.release_requested_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(order)
    return _order_out_single(db, order)


class PayoutRequest(BaseModel):
    bank_name: str
    account_holder: str
    account_number: str


class PayoutOut(BaseModel):
    order_count: int
    amount: float


@router.post("/request-payout", response_model=PayoutOut)
def request_payout(
    payload: PayoutRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PayoutOut:
    """Withdraw the seller's whole balance — every released order (the buyer
    already got the item) not yet withdrawn — to the given bank account.
    It only files a request — the money is sent
    (and `payout_eta_at` set) once the admin approves it."""
    bank_name = payload.bank_name.strip()
    holder = payload.account_holder.strip()
    number = payload.account_number.strip()
    if bank_name not in PAYOUT_BANKS:
        raise HTTPException(
            status_code=422, detail="Withdraw to ABA or Wing"
        )
    if not holder or not number.isdigit():
        raise HTTPException(status_code=422, detail="Enter valid bank details")

    auto_release_due_orders(db)

    orders = (
        db.query(Order)
        .filter(
            Order.seller_id == user.id,
            Order.status == STATUS_RELEASED,
            Order.payout_requested_at.is_(None),
        )
        .all()
    )
    if not orders:
        raise HTTPException(status_code=409, detail="No released balance to withdraw")

    now = datetime.now(timezone.utc)
    for order in orders:
        order.payout_requested_at = now
        order.payout_bank_name = bank_name
        order.payout_account_holder = holder
        order.payout_account_number = number
    db.commit()
    amount = round(sum(seller_amount_for(o) for o in orders), 2)
    return PayoutOut(order_count=len(orders), amount=amount)


@router.post("/{order_id}/release", response_model=OrderOut)
def release_order(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    """Buyer-confirmed release of held funds to the seller."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(status_code=403, detail="Only the buyer can release this order")

    now = datetime.now(timezone.utc)
    release_funds(db, order, now, fee_rate=fee_rate_for(db, order.seller_id))
    db.commit()
    db.refresh(order)
    notify_order_released(db, order)
    return _order_out_single(db, order)


@router.post("/{order_id}/cancel", response_model=OrderOut)
def cancel_order(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(status_code=403, detail="Only the buyer can cancel this order")

    _transition(order, STATUS_CANCELLED)
    order.cancelled_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(order)
    push_notification(
        db,
        order.seller_id,
        "order",
        "Order cancelled",
        f"The buyer cancelled the order for {order.product_name}.",
        NotificationTarget(route="sellerOrderDetail", params={"id": order.id}),
    )
    return _order_out_single(db, order)


class ReportRequest(BaseModel):
    reason: str
    note: str = ""


class ReportOut(BaseModel):
    id: str
    order_id: str
    reason: str
    note: str
    created_at: datetime

    model_config = {"from_attributes": True}


@router.post("/{order_id}/report", response_model=ReportOut)
def report_order(order_id: str, payload: ReportRequest, db: Session = Depends(get_db)) -> OrderReport:
    report = OrderReport(order_id=order_id, reason=payload.reason, note=payload.note)
    db.add(report)
    db.commit()
    db.refresh(report)
    return report


def _save_review_photos(buyer_id: str, photos: list[UploadFile]) -> list[str]:
    if len(photos) > _MAX_REVIEW_PHOTOS:
        raise HTTPException(
            status_code=400, detail=f"Up to {_MAX_REVIEW_PHOTOS} photos are allowed"
        )

    return [save_image_as_webp(photo, "review_photos", buyer_id) for photo in photos]


@router.post("/{order_id}/review", response_model=OrderOut)
def submit_order_review(
    order_id: str,
    rating: int = Form(...),
    comment: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> OrderOut:
    """Buyer rating + reviewing a completed order (rate_review_sheet.dart).
    One review per order — resubmitting updates the existing row rather than
    creating a second one. The updated order (with the review embedded) is
    returned so the caller can refresh its own screen immediately."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(status_code=403, detail="Only the buyer can review this order")
    if order.status != STATUS_RELEASED:
        raise HTTPException(
            status_code=409, detail="Order must be completed before it can be reviewed"
        )
    if not 1 <= rating <= 5:
        raise HTTPException(status_code=400, detail="Rating must be between 1 and 5")

    uploaded = [p for p in photos if p.filename]
    review = db.query(OrderReview).filter(OrderReview.order_id == order_id).one_or_none()
    photo_urls = (
        _save_review_photos(user.id, uploaded)
        if uploaded
        else (review.photo_urls if review else [])
    )

    if review is None:
        review = OrderReview(
            order_id=order_id,
            buyer_id=user.id,
            rating=rating,
            comment=comment.strip(),
            photo_urls=photo_urls,
        )
        db.add(review)
    else:
        review.rating = rating
        review.comment = comment.strip()
        review.photo_urls = photo_urls

    db.commit()
    db.refresh(order)
    return _order_out_single(db, order)
