import uuid
from datetime import datetime, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import CoBuyParticipant, CoBuyPool, Profile, Shop
from .listings import ColorOptionOut, _parse_colors, _parse_sizes
from .notifications import NotificationTarget, push_notification

router = APIRouter(prefix="/co-buy", tags=["co-buy"])

PHOTOS_DIR = Path(__file__).resolve().parent.parent / "media" / "co_buy_photos"
_ALLOWED_PHOTO_TYPES = {"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}
_MAX_PHOTOS = 4


class CoBuyPoolOut(BaseModel):
    id: str
    seller_id: str
    seller_name: str
    seller_logo_url: str
    seller_verified: bool
    seller_location: str
    product_name: str
    category: str
    description: str
    price: float
    original_price: float
    target_qty: int
    current_qty: int
    unit_label: str
    per_unit_label: str
    min_order_qty: int
    retailers_joined: int
    time_left: str
    auto_renew: bool
    photo_urls: list[str]
    sizes: list[str]
    colors: list[ColorOptionOut]
    weight: str
    origin: str
    grade: str
    packaging: str
    joined: bool
    # The viewer's own escrow state on this deal: None (not paid in),
    # "held", "leave_requested", or "released". `leave_admin_note` carries the
    # admin's reason when their last leave request was rejected.
    my_status: str | None = None
    my_leave_admin_note: str | None = None
    is_full: bool


def _save_photos(seller_id: str, photos: list[UploadFile]) -> list[str]:
    if len(photos) > _MAX_PHOTOS:
        raise HTTPException(
            status_code=400, detail=f"Up to {_MAX_PHOTOS} photos are allowed"
        )

    PHOTOS_DIR.mkdir(parents=True, exist_ok=True)
    urls = []
    for photo in photos:
        ext = _ALLOWED_PHOTO_TYPES.get(photo.content_type or "")
        if ext is None:
            raise HTTPException(status_code=400, detail="Unsupported image type")
        filename = f"{seller_id}-{uuid.uuid4().hex[:8]}{ext}"
        with (PHOTOS_DIR / filename).open("wb") as out:
            out.write(photo.file.read())
        urls.append(f"/media/co_buy_photos/{filename}")
    return urls


# Only paid participants count toward the pool. A pending leave request still
# counts until an admin approves it (-> `refunded`); an unpaid
# `pending_payment` reservation never does.
_COUNTED_STATUSES = ("held", "leave_requested", "released")


def _active_participants(db: Session, pool_id: str) -> list[CoBuyParticipant]:
    return (
        db.query(CoBuyParticipant)
        .filter(
            CoBuyParticipant.pool_id == pool_id,
            CoBuyParticipant.status.in_(_COUNTED_STATUSES),
        )
        .all()
    )


def _own_participant(
    db: Session, pool_id: str, buyer_id: str
) -> CoBuyParticipant | None:
    return (
        db.query(CoBuyParticipant)
        .filter(
            CoBuyParticipant.pool_id == pool_id,
            CoBuyParticipant.buyer_id == buyer_id,
        )
        .first()
    )


def _serialize_pool(pool: CoBuyPool, db: Session, viewer_id: str) -> CoBuyPoolOut:
    shop = db.get(Shop, pool.seller_id)
    profile = db.get(Profile, pool.seller_id)
    seller_name = (shop.shop_name if shop else "") or (profile.name if profile else "") or "Seller"
    participants = _active_participants(db, pool.id)
    current_qty = sum(p.quantity for p in participants)
    mine = next((p for p in participants if p.buyer_id == viewer_id), None)
    return CoBuyPoolOut(
        id=pool.id,
        seller_id=pool.seller_id,
        seller_name=seller_name,
        seller_logo_url=shop.logo_url if shop else "",
        seller_verified=bool(profile and profile.verification_status == "verified"),
        seller_location=shop.location if shop else "",
        product_name=pool.product_name,
        category=pool.category,
        description=pool.description,
        price=pool.price,
        original_price=pool.original_price,
        target_qty=pool.target_qty,
        current_qty=current_qty,
        unit_label=pool.unit_label,
        per_unit_label=pool.per_unit_label,
        min_order_qty=pool.min_order_qty,
        retailers_joined=len(participants),
        time_left=pool.time_left,
        auto_renew=pool.auto_renew,
        photo_urls=pool.photo_urls,
        sizes=pool.sizes,
        colors=[ColorOptionOut(**c) for c in pool.colors],
        weight=pool.weight,
        origin=pool.origin,
        grade=pool.grade,
        packaging=pool.packaging,
        joined=mine is not None,
        my_status=mine.status if mine else None,
        my_leave_admin_note=mine.leave_admin_note if mine else None,
        is_full=current_qty >= pool.target_qty,
    )


def _validate_pool_fields(
    product_name: str,
    price: float,
    original_price: float,
    target_qty: int,
    min_order_qty: int,
) -> str:
    product_name = product_name.strip()
    if not product_name:
        raise HTTPException(status_code=400, detail="Product name is required")
    if price <= 0:
        raise HTTPException(status_code=400, detail="Price must be greater than 0")
    if original_price <= price:
        raise HTTPException(
            status_code=400, detail="Original price must be greater than the deal price"
        )
    if target_qty <= 0:
        raise HTTPException(status_code=400, detail="Target quantity must be greater than 0")
    if min_order_qty <= 0:
        raise HTTPException(
            status_code=400, detail="Minimum order quantity must be greater than 0"
        )
    return product_name


@router.post("/pools", response_model=CoBuyPoolOut)
def create_pool(
    product_name: str = Form(...),
    category: str = Form(""),
    description: str = Form(""),
    price: float = Form(...),
    original_price: float = Form(...),
    target_qty: int = Form(...),
    unit_label: str = Form(...),
    per_unit_label: str = Form(...),
    min_order_qty: int = Form(...),
    time_left: str = Form(...),
    auto_renew: bool = Form(False),
    sizes: str = Form(""),
    colors: str = Form(""),
    weight: str = Form(""),
    origin: str = Form(""),
    grade: str = Form(""),
    packaging: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    product_name = _validate_pool_fields(
        product_name, price, original_price, target_qty, min_order_qty
    )
    photo_urls = _save_photos(user.id, [p for p in photos if p.filename])

    pool = CoBuyPool(
        seller_id=user.id,
        product_name=product_name,
        category=category.strip(),
        description=description.strip(),
        price=price,
        original_price=original_price,
        target_qty=target_qty,
        unit_label=unit_label.strip(),
        per_unit_label=per_unit_label.strip(),
        min_order_qty=min_order_qty,
        time_left=time_left,
        auto_renew=auto_renew,
        photo_urls=photo_urls,
        sizes=_parse_sizes(sizes),
        colors=_parse_colors(colors),
        weight=weight.strip(),
        origin=origin.strip(),
        grade=grade.strip(),
        packaging=packaging.strip(),
    )
    db.add(pool)
    db.commit()
    db.refresh(pool)
    push_notification(
        db,
        user.id,
        "co_buy",
        "Your co-buy deal is live",
        f"{pool.product_name} is now open for retailers to join.",
        NotificationTarget(route="coBuyDetail", params={"id": pool.id}),
    )
    return _serialize_pool(pool, db, user.id)


@router.get("/pools", response_model=list[CoBuyPoolOut])
def list_pools(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[CoBuyPoolOut]:
    pools = db.query(CoBuyPool).order_by(CoBuyPool.created_at.desc()).all()
    return [_serialize_pool(pool, db, user.id) for pool in pools]


@router.get("/pools/me", response_model=list[CoBuyPoolOut])
def list_my_pools(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[CoBuyPoolOut]:
    pools = (
        db.query(CoBuyPool)
        .filter(CoBuyPool.seller_id == user.id)
        .order_by(CoBuyPool.created_at.desc())
        .all()
    )
    return [_serialize_pool(pool, db, user.id) for pool in pools]


def _get_owned_pool(db: Session, user: CurrentUser, pool_id: str) -> CoBuyPool:
    pool = db.get(CoBuyPool, pool_id)
    if pool is None or pool.seller_id != user.id:
        raise HTTPException(status_code=404, detail="Co-buy deal not found")
    return pool


@router.put("/pools/me/{pool_id}", response_model=CoBuyPoolOut)
def update_pool(
    pool_id: str,
    product_name: str = Form(...),
    category: str = Form(""),
    description: str = Form(""),
    price: float = Form(...),
    original_price: float = Form(...),
    target_qty: int = Form(...),
    unit_label: str = Form(...),
    per_unit_label: str = Form(...),
    min_order_qty: int = Form(...),
    time_left: str = Form(...),
    auto_renew: bool = Form(False),
    sizes: str = Form(""),
    colors: str = Form(""),
    weight: str = Form(""),
    origin: str = Form(""),
    grade: str = Form(""),
    packaging: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    pool = _get_owned_pool(db, user, pool_id)
    product_name = _validate_pool_fields(
        product_name, price, original_price, target_qty, min_order_qty
    )

    uploaded = [p for p in photos if p.filename]
    if uploaded:
        pool.photo_urls = _save_photos(user.id, uploaded)

    pool.product_name = product_name
    pool.category = category.strip()
    pool.description = description.strip()
    pool.price = price
    pool.original_price = original_price
    pool.target_qty = target_qty
    pool.unit_label = unit_label.strip()
    pool.per_unit_label = per_unit_label.strip()
    pool.min_order_qty = min_order_qty
    pool.time_left = time_left
    pool.auto_renew = auto_renew
    pool.sizes = _parse_sizes(sizes)
    pool.colors = _parse_colors(colors)
    pool.weight = weight.strip()
    pool.origin = origin.strip()
    pool.grade = grade.strip()
    pool.packaging = packaging.strip()
    db.commit()
    db.refresh(pool)
    return _serialize_pool(pool, db, user.id)


@router.delete("/pools/me/{pool_id}", status_code=204)
def delete_pool(
    pool_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    pool = _get_owned_pool(db, user, pool_id)
    db.query(CoBuyParticipant).filter(CoBuyParticipant.pool_id == pool.id).delete()
    db.delete(pool)
    db.commit()


@router.get("/pools/{pool_id}", response_model=CoBuyPoolOut)
def get_pool(
    pool_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    pool = db.get(CoBuyPool, pool_id)
    if pool is None:
        raise HTTPException(status_code=404, detail="Co-buy deal not found")
    return _serialize_pool(pool, db, user.id)


class JoinPoolRequest(BaseModel):
    quantity: int
    size: str | None = None
    color_name: str | None = None
    color_hex: str | None = None


def _others_qty(db: Session, pool_id: str, buyer_id: str) -> int:
    return sum(
        p.quantity
        for p in _active_participants(db, pool_id)
        if p.buyer_id != buyer_id
    )


@router.post("/pools/{pool_id}/join", response_model=CoBuyPoolOut)
def join_pool(
    pool_id: str,
    body: JoinPoolRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    """Reserves a spot pending payment. The buyer only counts toward the pool
    (and shows as joined) once `/pay` moves the reservation into escrow."""
    pool = db.get(CoBuyPool, pool_id)
    if pool is None:
        raise HTTPException(status_code=404, detail="Co-buy deal not found")
    if body.quantity < pool.min_order_qty:
        raise HTTPException(
            status_code=400,
            detail=f"Quantity must be at least {pool.min_order_qty}",
        )

    mine = _own_participant(db, pool.id, user.id)
    if mine is not None and mine.status == "leave_requested":
        raise HTTPException(
            status_code=409,
            detail="Your leave request is awaiting admin review.",
        )
    if mine is not None and mine.status in ("held", "released"):
        raise HTTPException(
            status_code=409, detail="You've already joined and paid for this deal."
        )

    others_qty = _others_qty(db, pool.id, user.id)
    if others_qty + body.quantity > pool.target_qty:
        remaining = max(0, pool.target_qty - others_qty)
        raise HTTPException(
            status_code=409,
            detail=f"Only {remaining} {pool.unit_label} left in this deal",
        )

    if mine is None:
        mine = CoBuyParticipant(pool_id=pool.id, buyer_id=user.id, quantity=body.quantity)
        db.add(mine)
    # A fresh reservation, or a re-join after an approved refund: reset the
    # row's escrow trail so it starts clean.
    mine.status = "pending_payment"
    mine.quantity = body.quantity
    mine.size = body.size
    mine.color_name = body.color_name
    mine.color_hex = body.color_hex
    mine.payment_method = None
    mine.payment_reference = None
    mine.paid_at = None
    mine.leave_requested_at = None
    mine.refunded_at = None
    mine.leave_reason = None
    mine.leave_admin_note = None
    mine.leave_resolved_at = None
    db.commit()
    db.refresh(pool)
    return _serialize_pool(pool, db, user.id)


@router.delete("/pools/{pool_id}/join", response_model=CoBuyPoolOut)
def leave_pool(
    pool_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    """Drops an *unpaid* reservation (e.g. backing out of checkout). Once
    paid, leaving needs an admin's approval — see `/leave-request`."""
    pool = db.get(CoBuyPool, pool_id)
    if pool is None:
        raise HTTPException(status_code=404, detail="Co-buy deal not found")
    participant = _own_participant(db, pool.id, user.id)
    if participant is not None:
        if participant.status == "pending_payment":
            db.delete(participant)
        elif participant.status != "refunded":
            raise HTTPException(
                status_code=409,
                detail="You've paid for this deal. Request to leave with a reason instead.",
            )
    db.commit()
    db.refresh(pool)
    return _serialize_pool(pool, db, user.id)


class LeaveRequest(BaseModel):
    reason: str


@router.post("/pools/{pool_id}/leave-request", response_model=CoBuyPoolOut)
def request_leave(
    pool_id: str,
    body: LeaveRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    pool = db.get(CoBuyPool, pool_id)
    if pool is None:
        raise HTTPException(status_code=404, detail="Co-buy deal not found")
    reason = body.reason.strip()
    if len(reason) < 5:
        raise HTTPException(
            status_code=400, detail="Please tell us why you want to leave."
        )
    participant = _own_participant(db, pool.id, user.id)
    if participant is None or participant.status not in ("held", "leave_requested"):
        raise HTTPException(status_code=404, detail="You haven't paid into this deal")
    if participant.status == "leave_requested":
        raise HTTPException(
            status_code=409, detail="Your leave request is awaiting admin review."
        )

    participant.status = "leave_requested"
    participant.leave_reason = reason
    participant.leave_requested_at = datetime.now(timezone.utc)
    participant.leave_admin_note = None
    participant.leave_resolved_at = None
    db.commit()
    db.refresh(pool)
    return _serialize_pool(pool, db, user.id)


def remaining_qty(db: Session, pool: CoBuyPool) -> int:
    """Units still open in a deal — only paid joins count toward it."""
    taken = sum(p.quantity for p in _active_participants(db, pool.id))
    return max(0, pool.target_qty - taken)


def hold_join(
    db: Session,
    pool: CoBuyPool,
    participant: CoBuyParticipant,
    method: str,
    reference: str,
) -> None:
    """Moves a pending join into held escrow once ABA PayWay has confirmed its
    payment (routers/payments.py), then tells the seller (and everyone, if this filled the deal). Commits."""
    before = pool.target_qty - remaining_qty(db, pool)
    participant.status = "held"
    participant.payment_method = method
    participant.payment_reference = reference
    participant.paid_at = datetime.now(timezone.utc)
    db.commit()

    current = pool.target_qty - remaining_qty(db, pool)
    target = NotificationTarget(route="coBuyDetail", params={"id": pool.id})
    push_notification(
        db,
        pool.seller_id,
        "co_buy",
        "A retailer joined your co-buy",
        f"{pool.product_name}: {current}/{pool.target_qty} reached.",
        target,
    )
    if before < pool.target_qty <= current:
        body = f"{pool.product_name} hit its group buy target. Checkout closes soon."
        recipients = {p.buyer_id for p in _active_participants(db, pool.id)}
        recipients.add(pool.seller_id)
        for recipient in recipients:
            push_notification(
                db, recipient, "co_buy", "Co-buy target reached", body, target
            )
