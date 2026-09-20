from datetime import datetime, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Shop
from .orders import is_high_volume_seller
from ..utils.images import save_image_as_webp

router = APIRouter(prefix="/shop", tags=["shop"])

LOGO_DIR = Path(__file__).resolve().parent.parent / "media" / "shop_logos"
PHOTOS_DIR = Path(__file__).resolve().parent.parent / "media" / "shop_photos"
_MAX_STORE_PHOTOS = 4


class ShopOut(BaseModel):
    shop_name: str
    business_type: str
    store_type: str
    year_established: str
    location: str
    phone: str
    email: str
    description: str
    store_url: str
    logo_url: str = ""
    photo_urls: list[str] = []
    # "Power Seller" badge — see `is_high_volume_seller` in routers/orders.py.
    high_volume: bool = False

    model_config = {"from_attributes": True}


class ShopIn(BaseModel):
    shop_name: str
    business_type: str
    store_type: str = ""
    year_established: str
    location: str
    phone: str
    email: str
    description: str
    store_url: str = ""


def _get_or_create(db: Session, user: CurrentUser) -> Shop:
    shop = db.get(Shop, user.id)
    if shop is None:
        shop = Shop(id=user.id)
        db.add(shop)
        db.commit()
        db.refresh(shop)
    return shop


def _with_badge(db: Session, shop: Shop) -> ShopOut:
    out = ShopOut.model_validate(shop)
    out.high_volume = is_high_volume_seller(db, shop.id, datetime.now(timezone.utc))
    return out


@router.get("/me", response_model=ShopOut)
def get_shop(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> ShopOut:
    return _with_badge(db, _get_or_create(db, user))


@router.post("/me", response_model=ShopOut)
def save_shop(
    payload: ShopIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Shop:
    shop = _get_or_create(db, user)
    shop.shop_name = payload.shop_name.strip()
    shop.business_type = payload.business_type.strip()
    shop.store_type = payload.store_type.strip()
    shop.year_established = payload.year_established.strip()
    shop.location = payload.location.strip()
    shop.phone = payload.phone.strip()
    shop.email = payload.email.strip()
    shop.description = payload.description.strip()
    shop.store_url = payload.store_url.strip()
    db.commit()
    db.refresh(shop)
    return shop


@router.post("/me/logo", response_model=ShopOut)
def upload_logo(
    file: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Shop:
    filename = save_image_as_webp(file, LOGO_DIR, user.id)

    shop = _get_or_create(db, user)
    shop.logo_url = f"/media/shop_logos/{filename}"
    db.commit()
    db.refresh(shop)
    return shop


@router.post("/me/photos", response_model=ShopOut)
def upload_store_photos(
    photos: list[UploadFile] = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Shop:
    uploaded = [p for p in photos if p.filename]
    if len(uploaded) > _MAX_STORE_PHOTOS:
        raise HTTPException(
            status_code=400, detail=f"Up to {_MAX_STORE_PHOTOS} store photos are allowed"
        )

    urls = []
    for photo in uploaded:
        filename = save_image_as_webp(photo, PHOTOS_DIR, user.id)
        urls.append(f"/media/shop_photos/{filename}")

    shop = _get_or_create(db, user)
    shop.photo_urls = urls
    db.commit()
    db.refresh(shop)
    return shop


@router.get("/{seller_id}", response_model=ShopOut)
def get_shop_by_id(seller_id: str, db: Session = Depends(get_db)) -> ShopOut:
    return _with_badge(db, db.get(Shop, seller_id) or Shop(id=seller_id))
