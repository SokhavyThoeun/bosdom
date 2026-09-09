import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Shop

router = APIRouter(prefix="/shop", tags=["shop"])

LOGO_DIR = Path(__file__).resolve().parent.parent / "media" / "shop_logos"
_ALLOWED_LOGO_TYPES = {"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}


class ShopOut(BaseModel):
    shop_name: str
    business_type: str
    year_established: str
    location: str
    phone: str
    email: str
    description: str
    logo_url: str = ""

    model_config = {"from_attributes": True}


class ShopIn(BaseModel):
    shop_name: str
    business_type: str
    year_established: str
    location: str
    phone: str
    email: str
    description: str


def _get_or_create(db: Session, user: CurrentUser) -> Shop:
    shop = db.get(Shop, user.id)
    if shop is None:
        shop = Shop(id=user.id)
        db.add(shop)
        db.commit()
        db.refresh(shop)
    return shop


@router.get("/me", response_model=ShopOut)
def get_shop(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> Shop:
    return _get_or_create(db, user)


@router.post("/me", response_model=ShopOut)
def save_shop(
    payload: ShopIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Shop:
    shop = _get_or_create(db, user)
    shop.shop_name = payload.shop_name.strip()
    shop.business_type = payload.business_type.strip()
    shop.year_established = payload.year_established.strip()
    shop.location = payload.location.strip()
    shop.phone = payload.phone.strip()
    shop.email = payload.email.strip()
    shop.description = payload.description.strip()
    db.commit()
    db.refresh(shop)
    return shop


@router.post("/me/logo", response_model=ShopOut)
def upload_logo(
    file: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Shop:
    ext = _ALLOWED_LOGO_TYPES.get(file.content_type or "")
    if ext is None:
        raise HTTPException(status_code=400, detail="Unsupported image type")

    LOGO_DIR.mkdir(parents=True, exist_ok=True)
    filename = f"{user.id}-{uuid.uuid4().hex[:8]}{ext}"
    with (LOGO_DIR / filename).open("wb") as out:
        out.write(file.file.read())

    shop = _get_or_create(db, user)
    shop.logo_url = f"/media/shop_logos/{filename}"
    db.commit()
    db.refresh(shop)
    return shop
