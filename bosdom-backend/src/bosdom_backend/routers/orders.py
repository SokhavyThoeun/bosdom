import io
import uuid
from datetime import datetime, timezone

import qrcode
from fastapi import APIRouter, Depends, HTTPException, Response
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Listing, Order, OrderReport

router = APIRouter(prefix="/orders", tags=["orders"])

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

# Payment methods mirror the frontend's `_PaymentMethod` enum
# (payment_screen.dart) — this backend has no real Stripe/Bakong
# integration, so "paying" just moves the order into `held`.
_MOCK_PAYMENT_METHODS = {"card", "khqr", "aba"}


def _transition(order: Order, new_status: str) -> None:
    allowed = _VALID_TRANSITIONS.get(order.status, set())
    if new_status not in allowed:
        raise HTTPException(
            status_code=409,
            detail=f"Cannot move order from '{order.status}' to '{new_status}'",
        )
    order.status = new_status


def _ensure_delivery_code(order: Order, db: Session) -> str:
    """Lazily assigns a delivery-confirmation code to orders that predate
    this column (15.3) instead of requiring a backfill migration."""
    if not order.delivery_confirmation_code:
        order.delivery_confirmation_code = uuid.uuid4().hex[:8].upper()
        db.commit()
        db.refresh(order)
    return order.delivery_confirmation_code


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


class OrderPayRequest(BaseModel):
    payment_method: str


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
    released_at: datetime | None
    cancelled_at: datetime | None

    model_config = {"from_attributes": True}


@router.get("/me", response_model=list[OrderOut])
def list_my_orders(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[Order]:
    return (
        db.query(Order)
        .filter(Order.buyer_id == user.id)
        .order_by(Order.created_at.desc())
        .all()
    )


@router.get("/me/selling", response_model=list[OrderOut])
def list_my_sales(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[Order]:
    return (
        db.query(Order)
        .filter(Order.seller_id == user.id)
        .order_by(Order.created_at.desc())
        .all()
    )


@router.post("", response_model=OrderOut)
def create_order(
    payload: OrderCreate,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Order:
    if payload.quantity < 1:
        raise HTTPException(status_code=400, detail="Quantity must be at least 1")

    listing = db.get(Listing, payload.listing_id)
    if listing is None:
        raise HTTPException(status_code=404, detail="Listing not found")

    order = Order(
        buyer_id=user.id,
        seller_id=listing.seller_id,
        listing_id=listing.id,
        product_name=listing.product_name,
        unit_price=listing.price,
        quantity=payload.quantity,
        total_amount=listing.price * payload.quantity,
        shipping_name=payload.shipping_name,
        shipping_address=payload.shipping_address,
        shipping_phone=payload.shipping_phone,
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order


@router.get("/{order_id}", response_model=OrderOut)
def get_order(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Order:
    return _get_participant_order(db, order_id, user.id)


@router.post("/{order_id}/pay", response_model=OrderOut)
def pay_order(
    order_id: str,
    payload: OrderPayRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Order:
    """Mock payment gateway (15.2): no real Stripe/Bakong call — this just
    simulates the gateway succeeding and holding the funds in escrow."""
    if payload.payment_method not in _MOCK_PAYMENT_METHODS:
        raise HTTPException(status_code=400, detail="Unsupported payment method")

    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(status_code=403, detail="Only the buyer can pay for this order")

    _transition(order, STATUS_HELD)
    order.payment_method = payload.payment_method
    order.payment_reference = f"MOCK-{uuid.uuid4().hex[:12].upper()}"
    order.paid_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(order)
    return order


@router.post("/{order_id}/release", response_model=OrderOut)
def release_order(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Order:
    """Buyer-confirmed release of held funds to the seller — a manual
    fallback for when scanning isn't possible. `POST .../confirm-delivery`
    (15.3) drives this same transition automatically off a QR scan instead."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(status_code=403, detail="Only the buyer can release this order")

    _transition(order, STATUS_RELEASED)
    order.released_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(order)
    return order


@router.get("/{order_id}/qr")
def get_delivery_qr(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Response:
    """PNG QR code the seller shows at handoff; the buyer scans it in-app to
    confirm delivery (`POST .../confirm-delivery`). Only meaningful once
    funds are actually held — an unpaid or already-settled order has nothing
    to confirm."""
    order = _get_participant_order(db, order_id, user.id)
    if order.status != STATUS_HELD:
        raise HTTPException(
            status_code=409,
            detail=f"Order must be '{STATUS_HELD}' to generate a delivery QR code",
        )

    code = _ensure_delivery_code(order, db)
    payload = f"bosdom://orders/{order.id}/confirm-delivery?code={code}"

    image = qrcode.make(payload)
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    return Response(content=buffer.getvalue(), media_type="image/png")


class ConfirmDeliveryRequest(BaseModel):
    code: str


@router.post("/{order_id}/confirm-delivery", response_model=OrderOut)
def confirm_delivery(
    order_id: str,
    payload: ConfirmDeliveryRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Order:
    """Buyer scans the seller's QR (`GET .../qr`) to confirm delivery, which
    releases escrow the same way a manual `.../release` tap would — proof of
    a physical handoff rather than a bare self-reported tap."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(
            status_code=403, detail="Only the buyer can confirm delivery for this order"
        )
    if order.status != STATUS_HELD:
        raise HTTPException(
            status_code=409,
            detail=f"Order must be '{STATUS_HELD}' to confirm delivery",
        )
    if not order.delivery_confirmation_code or payload.code.strip().upper() != order.delivery_confirmation_code:
        raise HTTPException(status_code=400, detail="Invalid delivery confirmation code")

    _transition(order, STATUS_RELEASED)
    order.released_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(order)
    return order


@router.post("/{order_id}/cancel", response_model=OrderOut)
def cancel_order(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Order:
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(status_code=403, detail="Only the buyer can cancel this order")

    _transition(order, STATUS_CANCELLED)
    order.cancelled_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(order)
    return order


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
