import uuid
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
    joined: bool
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


def _serialize_pool(pool: CoBuyPool, db: Session, viewer_id: str) -> CoBuyPoolOut:
    shop = db.get(Shop, pool.seller_id)
    profile = db.get(Profile, pool.seller_id)
    seller_name = (shop.shop_name if shop else "") or (profile.name if profile else "") or "Seller"
    participants = (
        db.query(CoBuyParticipant).filter(CoBuyParticipant.pool_id == pool.id).all()
    )
    current_qty = sum(p.quantity for p in participants)
    return CoBuyPoolOut(
        id=pool.id,
        seller_id=pool.seller_id,
        seller_name=seller_name,
        seller_logo_url=shop.logo_url if shop else "",
        seller_verified=bool(profile and profile.verification_status == "verified"),
        seller_location=shop.location if shop else "",
        product_name=pool.product_name,
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
        joined=any(p.buyer_id == viewer_id for p in participants),
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
    )
    db.add(pool)
    db.commit()
    db.refresh(pool)
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


@router.post("/pools/{pool_id}/join", response_model=CoBuyPoolOut)
def join_pool(
    pool_id: str,
    body: JoinPoolRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    pool = db.get(CoBuyPool, pool_id)
    if pool is None:
        raise HTTPException(status_code=404, detail="Co-buy deal not found")
    if body.quantity < pool.min_order_qty:
        raise HTTPException(
            status_code=400,
            detail=f"Quantity must be at least {pool.min_order_qty}",
        )

    participants = (
        db.query(CoBuyParticipant).filter(CoBuyParticipant.pool_id == pool.id).all()
    )
    current_qty_before = sum(p.quantity for p in participants)
    was_full = current_qty_before >= pool.target_qty
    existing = next((p for p in participants if p.buyer_id == user.id), None)
    others_qty = current_qty_before - (existing.quantity if existing else 0)

    if others_qty + body.quantity > pool.target_qty:
        remaining = max(0, pool.target_qty - others_qty)
        raise HTTPException(
            status_code=409,
            detail=f"Only {remaining} {pool.unit_label} left in this deal",
        )

    if existing is not None:
        existing.quantity = body.quantity
        existing.size = body.size
        existing.color_name = body.color_name
        existing.color_hex = body.color_hex
    else:
        db.add(
            CoBuyParticipant(
                pool_id=pool.id,
                buyer_id=user.id,
                quantity=body.quantity,
                size=body.size,
                color_name=body.color_name,
                color_hex=body.color_hex,
            )
        )
    db.commit()
    db.refresh(pool)

    result = _serialize_pool(pool, db, user.id)
    if not was_full and result.is_full:
        push_notification(
            category="co_buy",
            title="Co-buy target reached",
            body=f"{pool.product_name} hit its group buy target. Checkout closes soon.",
            target=NotificationTarget(route="coBuyDetail", params={"id": pool.id}),
        )
    return result


@router.delete("/pools/{pool_id}/join", response_model=CoBuyPoolOut)
def leave_pool(
    pool_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CoBuyPoolOut:
    pool = db.get(CoBuyPool, pool_id)
    if pool is None:
        raise HTTPException(status_code=404, detail="Co-buy deal not found")
    db.query(CoBuyParticipant).filter(
        CoBuyParticipant.pool_id == pool.id, CoBuyParticipant.buyer_id == user.id
    ).delete()
    db.commit()
    db.refresh(pool)
    return _serialize_pool(pool, db, user.id)
