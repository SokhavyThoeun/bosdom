import uuid
from datetime import datetime, timedelta, timezone
from html import escape

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import HTMLResponse
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session

from .. import payway
from ..auth import CurrentUser, get_current_user
from ..config import settings
from ..db import get_db
from ..models import CoBuyParticipant, CoBuyPool, Order, PaywayPayment
from .co_buy import _own_participant, hold_join, remaining_qty
from .notifications import NotificationTarget, push_notification
from .orders import STATUS_PENDING_PAYMENT, _aware, mark_order_paid

router = APIRouter(prefix="/payments", tags=["payments"])

# Same rate as the checkout screen's escrow fee (`_escrowFee`), charged on
# items + shipping.
ESCROW_FEE_RATE = 0.02

# Matches the KHQR sheet's countdown. PayWay's minimum is 3 minutes.
KHQR_LIFETIME = timedelta(minutes=5)

# Time to type card details (and pass 3-D Secure) on PayWay's page.
CARD_LIFETIME = timedelta(minutes=15)

# PayWay can still report a QR as pending for a moment after it lapses, so
# only give up on it a little after its own expiry.
_EXPIRY_GRACE = timedelta(minutes=2)

# Shipping is still estimated on the device (shipping_fee_calculator.dart);
# anything above this is not a real courier quote.
_MAX_SHIPPING_FEE = 500.0

PAYMENT_PENDING = "pending"
PAYMENT_PAID = "paid"
PAYMENT_EXPIRED = "expired"
PAYMENT_FAILED = "failed"
PAYMENT_REFUND_DUE = "refund_due"


class PaymentStartRequest(BaseModel):
    # Exactly one of these: the escrow orders from one checkout, or the
    # buyer's pending join on a co-buy deal.
    order_ids: list[str] = []
    co_buy_pool_id: str | None = None
    shipping_fee: float = 0


class KhqrStartOut(BaseModel):
    tran_id: str
    amount: float
    currency: str
    qr_string: str
    deeplink: str
    expires_at: datetime
    # Sandbox only: the app calls `/sandbox-approve` after this many seconds
    # to stand in for a scan (see `sandbox_approve`). None on production.
    sandbox_approve_after_seconds: int | None = None


class CardStartOut(BaseModel):
    tran_id: str
    amount: float
    currency: str
    # Page the app's WebView opens; it posts the signed form to PayWay.
    checkout_url: str
    # The WebView closes once PayWay sends the buyer to either of these.
    success_url: str
    cancel_url: str
    expires_at: datetime


class PaymentStatusOut(BaseModel):
    tran_id: str
    status: str
    amount: float
    currency: str
    expires_at: datetime
    paid_at: datetime | None


class PaywayCallback(BaseModel):
    model_config = ConfigDict(extra="allow")

    tran_id: str


def _new_tran_id() -> str:
    # PayWay caps `tran_id` at 20 characters.
    return f"BD{uuid.uuid4().hex[:18].upper()}"


def _status_out(payment: PaywayPayment) -> PaymentStatusOut:
    return PaymentStatusOut(
        tran_id=payment.tran_id,
        status=payment.status,
        amount=payment.amount,
        currency=payment.currency,
        expires_at=payment.expires_at,
        paid_at=payment.paid_at,
    )


def _settle(db: Session, payment: PaywayPayment, apv: str, now: datetime) -> None:
    """PayWay approved the payment: move what it paid for into held escrow."""
    payment.status = PAYMENT_PAID
    payment.apv = apv
    payment.paid_at = now
    db.commit()

    if payment.co_buy_participant_id is None:
        for order_id in payment.order_ids:
            order = db.get(Order, order_id)
            if order is not None and order.status == STATUS_PENDING_PAYMENT:
                mark_order_paid(db, order, payment.payment_option, payment.tran_id)
        return

    participant = db.get(CoBuyParticipant, payment.co_buy_participant_id)
    pool = db.get(CoBuyPool, participant.pool_id) if participant else None
    if (
        participant is not None
        and pool is not None
        and participant.status == "pending_payment"
        and participant.quantity <= remaining_qty(db, pool)
    ):
        hold_join(db, pool, participant, payment.payment_option, payment.tran_id)
        return

    # The deal filled up (or the join was dropped) while the buyer was
    # scanning — the money came in but there's no spot left to hold it for.
    if participant is not None and participant.status == "pending_payment":
        db.delete(participant)
    payment.status = PAYMENT_REFUND_DUE
    db.commit()
    push_notification(
        db,
        payment.buyer_id,
        "payment",
        "Co-buy deal already full",
        f"We received your ${payment.amount:.2f} payment, but the deal filled up first. It will be refunded.",
        NotificationTarget(route="coBuyDetail", params={"id": pool.id})
        if pool is not None
        else None,
    )


def sync_payment(db: Session, payment: PaywayPayment) -> None:
    """Brings a pending payment up to date with PayWay's Check Transaction —
    the only thing trusted to say a payment went through."""
    if payment.status != PAYMENT_PENDING:
        return
    # Row lock so a PayWay callback and the app's status poll can't both
    # settle the same payment.
    payment = (
        db.query(PaywayPayment)
        .filter(PaywayPayment.tran_id == payment.tran_id)
        .with_for_update()
        .populate_existing()
        .one()
    )
    if payment.status != PAYMENT_PENDING:
        db.rollback()
        return

    now = datetime.now(timezone.utc)
    lapsed = now > _aware(payment.expires_at) + _EXPIRY_GRACE
    try:
        tx = payway.check_transaction(payment.tran_id)
    except payway.PayWayError:
        # PayWay may not know the transaction at all (a card page that was
        # never opened), or be briefly unreachable: keep it pending for the
        # next poll until its time is up.
        if lapsed:
            payment.status = PAYMENT_EXPIRED
            db.commit()
        else:
            db.rollback()
        return

    if tx.code == payway.STATUS_APPROVED:
        if abs(tx.total_amount - payment.amount) > 0.005:
            payment.status = PAYMENT_REFUND_DUE
            db.commit()
            return
        _settle(db, payment, tx.apv, now)
        return
    if tx.code in (
        payway.STATUS_DECLINED,
        payway.STATUS_CANCELLED,
        payway.STATUS_REFUNDED,
    ):
        payment.status = PAYMENT_FAILED
    elif lapsed:
        payment.status = PAYMENT_EXPIRED
    db.commit()


def _open_payment(
    payload: PaymentStartRequest, user: CurrentUser, db: Session
) -> tuple[list[str], str | None, float]:
    """Checks what a new payment would cover and works out its amount.
    Returns (order ids, co-buy participant id, amount in USD)."""
    if not payway.is_configured():
        raise HTTPException(status_code=503, detail="Online payments are unavailable")
    if bool(payload.order_ids) == bool(payload.co_buy_pool_id):
        raise HTTPException(
            status_code=422, detail="Pay for either orders or a co-buy join"
        )
    if not 0 <= payload.shipping_fee <= _MAX_SHIPPING_FEE:
        raise HTTPException(status_code=422, detail="Invalid shipping fee")

    # An earlier QR or card page may have been paid after all — settle
    # those first so this can't charge the buyer twice.
    earlier = (
        db.query(PaywayPayment)
        .filter(
            PaywayPayment.buyer_id == user.id,
            PaywayPayment.status == PAYMENT_PENDING,
        )
        .all()
    )
    for payment in earlier:
        sync_payment(db, payment)

    participant_id: str | None = None
    if payload.order_ids:
        orders = [db.get(Order, order_id) for order_id in payload.order_ids]
        if any(o is None or o.buyer_id != user.id for o in orders):
            raise HTTPException(status_code=404, detail="Order not found")
        if any(o.status != STATUS_PENDING_PAYMENT for o in orders):
            raise HTTPException(status_code=409, detail="This order is already paid")
        subtotal = sum(o.total_amount for o in orders)
    else:
        pool = db.get(CoBuyPool, payload.co_buy_pool_id)
        if pool is None:
            raise HTTPException(status_code=404, detail="Co-buy deal not found")
        participant = _own_participant(db, pool.id, user.id)
        if participant is None:
            raise HTTPException(status_code=404, detail="Join this deal before paying")
        if participant.status != "pending_payment":
            raise HTTPException(status_code=409, detail="This join is already paid")
        left = remaining_qty(db, pool)
        if participant.quantity > left:
            db.delete(participant)
            db.commit()
            raise HTTPException(
                status_code=409,
                detail=f"Only {left} {pool.unit_label} left in this deal",
            )
        participant_id = participant.id
        subtotal = pool.price * participant.quantity

    amount = round((subtotal + payload.shipping_fee) * (1 + ESCROW_FEE_RATE), 2)
    return list(payload.order_ids), participant_id, amount


def _callback_url() -> str | None:
    if not settings.public_base_url:
        return None
    return f"{settings.public_base_url.rstrip('/')}/payments/payway/callback"


@router.post("/khqr", response_model=KhqrStartOut)
def start_khqr(
    payload: PaymentStartRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> KhqrStartOut:
    """Opens a PayWay KHQR transaction for one checkout's orders (or one
    co-buy join) and returns the QR to show. Nothing is marked paid here —
    that happens in `sync_payment` once PayWay approves it."""
    order_ids, participant_id, amount = _open_payment(payload, user, db)
    tran_id = _new_tran_id()
    try:
        checkout = payway.create_khqr(
            tran_id,
            amount,
            lifetime_minutes=int(KHQR_LIFETIME.total_seconds() // 60),
            callback_url=_callback_url(),
        )
    except payway.PayWayError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e

    payment = PaywayPayment(
        tran_id=tran_id,
        buyer_id=user.id,
        order_ids=order_ids,
        co_buy_participant_id=participant_id,
        amount=amount,
        currency="USD",
        payment_option="khqr",
        expires_at=datetime.now(timezone.utc) + KHQR_LIFETIME,
    )
    db.add(payment)
    db.commit()
    approve_after = settings.payway_sandbox_khqr_approve_seconds
    return KhqrStartOut(
        tran_id=tran_id,
        amount=amount,
        currency="USD",
        qr_string=checkout.qr_string,
        deeplink=checkout.deeplink,
        expires_at=payment.expires_at,
        sandbox_approve_after_seconds=approve_after
        if payway.is_sandbox() and approve_after > 0
        else None,
    )


@router.post("/{tran_id}/sandbox-approve", response_model=PaymentStatusOut)
def sandbox_approve(
    tran_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaymentStatusOut:
    """Stands in for a KHQR scan on the PayWay sandbox, whose QR codes no
    real banking app can pay. Refused on production, and for cards (the
    sandbox test cards pay for real)."""
    if not payway.is_sandbox() or settings.payway_sandbox_khqr_approve_seconds <= 0:
        raise HTTPException(status_code=404, detail="Not found")
    payment = db.get(PaywayPayment, tran_id)
    if payment is None or payment.buyer_id != user.id:
        raise HTTPException(status_code=404, detail="Payment not found")
    if payment.payment_option != "khqr":
        raise HTTPException(status_code=409, detail="Only KHQR payments")
    if payment.status == PAYMENT_PENDING:
        _settle(db, payment, "SANDBOX", datetime.now(timezone.utc))
    db.refresh(payment)
    return _status_out(payment)


@router.post("/card", response_model=CardStartOut)
def start_card(
    payload: PaymentStartRequest,
    request: Request,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CardStartOut:
    """Opens a Visa/Mastercard/UnionPay/JCB payment. The app shows
    `checkout_url` in a WebView, which hands the buyer to PayWay's hosted
    card page; like KHQR, it's only marked paid once PayWay approves it."""
    order_ids, participant_id, amount = _open_payment(payload, user, db)
    payment = PaywayPayment(
        tran_id=_new_tran_id(),
        buyer_id=user.id,
        order_ids=order_ids,
        co_buy_participant_id=participant_id,
        amount=amount,
        currency="USD",
        payment_option="card",
        expires_at=datetime.now(timezone.utc) + CARD_LIFETIME,
    )
    db.add(payment)
    db.commit()

    # The phone reached this backend at `request.base_url`, so PayWay's
    # redirects back to it land on an address the WebView can load.
    base = f"{str(request.base_url).rstrip('/')}/payments/card/{payment.tran_id}"
    return CardStartOut(
        tran_id=payment.tran_id,
        amount=amount,
        currency="USD",
        checkout_url=f"{base}/checkout",
        success_url=f"{base}/done",
        cancel_url=f"{base}/cancel",
        expires_at=payment.expires_at,
    )


def _page(title: str, body: str) -> HTMLResponse:
    return HTMLResponse(
        "<!doctype html><html><head>"
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        f"<title>{escape(title)}</title>"
        "<style>body{font-family:-apple-system,system-ui,sans-serif;"
        "display:flex;align-items:center;justify-content:center;height:100vh;"
        "margin:0;color:#333;text-align:center;padding:0 24px}</style>"
        f"</head><body>{body}</body></html>"
    )


@router.get("/card/{tran_id}/checkout", response_class=HTMLResponse)
def card_checkout(
    tran_id: str, request: Request, db: Session = Depends(get_db)
) -> HTMLResponse:
    """Auto-submitting form that posts the signed Purchase fields to PayWay,
    which answers with its card entry page. Opened by the app's WebView, so
    there's no bearer token — the random, short-lived `tran_id` stands in."""
    payment = db.get(PaywayPayment, tran_id)
    if (
        payment is None
        or payment.payment_option != "card"
        or payment.status != PAYMENT_PENDING
        or datetime.now(timezone.utc) > _aware(payment.expires_at)
    ):
        return _page("Payment unavailable", "<p>This payment link has expired.</p>")

    base = f"{str(request.base_url).rstrip('/')}/payments/card/{tran_id}"
    left = _aware(payment.expires_at) - datetime.now(timezone.utc)
    try:
        fields = payway.card_checkout_fields(
            tran_id,
            payment.amount,
            success_url=f"{base}/done",
            cancel_url=f"{base}/cancel",
            # PayWay's minimum lifetime is 3 minutes.
            lifetime_minutes=max(3, int(left.total_seconds() // 60)),
            callback_url=_callback_url(),
        )
    except payway.PayWayError:
        return _page("Payment unavailable", "<p>Card payments are unavailable.</p>")

    inputs = "".join(
        f'<input type="hidden" name="{escape(k)}" value="{escape(v)}">'
        for k, v in fields.items()
    )
    return _page(
        "Redirecting to PayWay",
        f'<form id="payway" method="POST" action="{escape(payway.purchase_url())}">'
        f"{inputs}</form><p>Opening secure checkout…</p>"
        "<script>document.getElementById('payway').submit()</script>",
    )


@router.get("/card/{tran_id}/done", response_class=HTMLResponse)
def card_done(tran_id: str) -> HTMLResponse:
    # The app's WebView closes on reaching this URL; the page only shows if
    # it's opened some other way.
    return _page("Payment submitted", "<p>You can go back to BosDom now.</p>")


@router.get("/card/{tran_id}/cancel", response_class=HTMLResponse)
def card_cancel(tran_id: str) -> HTMLResponse:
    return _page("Payment cancelled", "<p>You can go back to BosDom now.</p>")


@router.post("/payway/callback")
def payway_callback(
    payload: PaywayCallback, db: Session = Depends(get_db)
) -> dict[str, str]:
    """PayWay's server-to-server notice that a transaction changed. Its body
    isn't trusted — it only prompts a Check Transaction lookup, so a forged
    callback can't mark anything paid."""
    payment = db.get(PaywayPayment, payload.tran_id)
    if payment is not None:
        sync_payment(db, payment)
    return {"status": "ok"}


@router.get("/{tran_id}", response_model=PaymentStatusOut)
def payment_status(
    tran_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaymentStatusOut:
    """Polled by the KHQR sheet until the payment settles."""
    payment = db.get(PaywayPayment, tran_id)
    if payment is None or payment.buyer_id != user.id:
        raise HTTPException(status_code=404, detail="Payment not found")
    sync_payment(db, payment)
    db.refresh(payment)
    return _status_out(payment)
