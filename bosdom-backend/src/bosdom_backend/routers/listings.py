import json
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile
from pydantic import BaseModel
from sqlalchemy import or_
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Listing

router = APIRouter(prefix="/listings", tags=["listings"])

PHOTOS_DIR = Path(__file__).resolve().parent.parent / "media" / "listing_photos"
_ALLOWED_PHOTO_TYPES = {"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}
_MAX_PHOTOS = 5


class ColorOptionOut(BaseModel):
    name: str
    hex: str


class ListingOut(BaseModel):
    id: str
    product_name: str
    category: str
    price: float
    moq_qty: int
    stock_qty: int
    description: str
    sample_testing_enabled: bool
    sample_price: float | None
    photo_urls: list[str]
    sizes: list[str]
    colors: list[ColorOptionOut]

    model_config = {"from_attributes": True}


def _parse_sizes(raw: str) -> list[str]:
    return [s.strip() for s in raw.split(",") if s.strip()]


def _parse_colors(raw: str) -> list[dict]:
    if not raw:
        return []
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise HTTPException(status_code=400, detail="Invalid colors payload") from exc
    if not isinstance(parsed, list) or not all(
        isinstance(c, dict) and isinstance(c.get("name"), str) and isinstance(c.get("hex"), str)
        for c in parsed
    ):
        raise HTTPException(status_code=400, detail="Invalid colors payload")
    return [{"name": c["name"], "hex": c["hex"]} for c in parsed]


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
        urls.append(f"/media/listing_photos/{filename}")
    return urls


@router.post("/me", response_model=ListingOut)
def create_listing(
    product_name: str = Form(...),
    category: str = Form(...),
    price: float = Form(...),
    moq_qty: int = Form(...),
    stock_qty: int = Form(...),
    description: str = Form(""),
    sample_testing_enabled: bool = Form(False),
    sample_price: float | None = Form(None),
    sizes: str = Form(""),
    colors: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Listing:
    product_name = product_name.strip()
    category = category.strip()
    if not product_name:
        raise HTTPException(status_code=400, detail="Product name is required")
    if not category:
        raise HTTPException(status_code=400, detail="Category is required")
    if price <= 0:
        raise HTTPException(status_code=400, detail="Price must be greater than 0")
    if moq_qty <= 0:
        raise HTTPException(
            status_code=400, detail="Minimum order quantity must be greater than 0"
        )
    if stock_qty < 0:
        raise HTTPException(status_code=400, detail="Stock quantity cannot be negative")
    if sample_testing_enabled and (sample_price is None or sample_price <= 0):
        raise HTTPException(
            status_code=400,
            detail="Sample price must be greater than 0 when sample testing is enabled",
        )

    photo_urls = _save_photos(user.id, [p for p in photos if p.filename])

    listing = Listing(
        seller_id=user.id,
        product_name=product_name,
        category=category,
        price=price,
        moq_qty=moq_qty,
        stock_qty=stock_qty,
        description=description.strip(),
        sample_testing_enabled=sample_testing_enabled,
        sample_price=sample_price if sample_testing_enabled else None,
        photo_urls=photo_urls,
        sizes=_parse_sizes(sizes),
        colors=_parse_colors(colors),
    )
    db.add(listing)
    db.commit()
    db.refresh(listing)
    return listing


@router.get("/me", response_model=list[ListingOut])
def list_my_listings(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[Listing]:
    return (
        db.query(Listing)
        .filter(Listing.seller_id == user.id)
        .order_by(Listing.created_at.desc())
        .all()
    )


def _get_owned_listing(db: Session, user: CurrentUser, listing_id: str) -> Listing:
    listing = db.get(Listing, listing_id)
    if listing is None or listing.seller_id != user.id:
        raise HTTPException(status_code=404, detail="Listing not found")
    return listing


@router.put("/me/{listing_id}", response_model=ListingOut)
def update_listing(
    listing_id: str,
    product_name: str = Form(...),
    category: str = Form(...),
    price: float = Form(...),
    moq_qty: int = Form(...),
    stock_qty: int = Form(...),
    description: str = Form(""),
    sample_testing_enabled: bool = Form(False),
    sample_price: float | None = Form(None),
    sizes: str = Form(""),
    colors: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Listing:
    listing = _get_owned_listing(db, user, listing_id)

    product_name = product_name.strip()
    category = category.strip()
    if not product_name:
        raise HTTPException(status_code=400, detail="Product name is required")
    if not category:
        raise HTTPException(status_code=400, detail="Category is required")
    if price <= 0:
        raise HTTPException(status_code=400, detail="Price must be greater than 0")
    if moq_qty <= 0:
        raise HTTPException(
            status_code=400, detail="Minimum order quantity must be greater than 0"
        )
    if stock_qty < 0:
        raise HTTPException(status_code=400, detail="Stock quantity cannot be negative")
    if sample_testing_enabled and (sample_price is None or sample_price <= 0):
        raise HTTPException(
            status_code=400,
            detail="Sample price must be greater than 0 when sample testing is enabled",
        )

    uploaded = [p for p in photos if p.filename]
    if uploaded:
        listing.photo_urls = _save_photos(user.id, uploaded)

    listing.product_name = product_name
    listing.category = category
    listing.price = price
    listing.moq_qty = moq_qty
    listing.stock_qty = stock_qty
    listing.description = description.strip()
    listing.sample_testing_enabled = sample_testing_enabled
    listing.sample_price = sample_price if sample_testing_enabled else None
    listing.sizes = _parse_sizes(sizes)
    listing.colors = _parse_colors(colors)
    db.commit()
    db.refresh(listing)
    return listing


@router.delete("/me/{listing_id}", status_code=204)
def delete_listing(
    listing_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    listing = _get_owned_listing(db, user, listing_id)
    db.delete(listing)
    db.commit()


@router.get("", response_model=list[ListingOut])
def search_listings(
    q: str | None = Query(default=None, description="Search product name/description"),
    category: str | None = Query(default=None),
    seller_id: str | None = Query(default=None),
    db: Session = Depends(get_db),
) -> list[Listing]:
    query = db.query(Listing)
    if category:
        query = query.filter(Listing.category == category)
    if seller_id:
        query = query.filter(Listing.seller_id == seller_id)
    if q:
        pattern = f"%{q.strip()}%"
        query = query.filter(
            or_(Listing.product_name.ilike(pattern), Listing.description.ilike(pattern))
        )
    return query.order_by(Listing.created_at.desc()).all()


@router.get("/{listing_id}", response_model=ListingOut)
def get_listing(listing_id: str, db: Session = Depends(get_db)) -> Listing:
    listing = db.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status_code=404, detail="Listing not found")
    return listing
