import json
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile
from pydantic import BaseModel
from sqlalchemy import or_
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user, require_verified_seller
from ..db import get_db
from ..models import Listing, Profile, Shop
from ..utils.images import save_image_as_webp

router = APIRouter(prefix="/listings", tags=["listings"])

PHOTOS_DIR = Path(__file__).resolve().parent.parent / "media" / "listing_photos"
_MAX_PHOTOS = 5


class ColorOptionOut(BaseModel):
    name: str
    hex: str


class ListingOut(BaseModel):
    id: str
    seller_id: str
    seller_name: str
    seller_logo_url: str
    seller_verified: bool
    seller_location: str
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
    weight: str
    origin: str
    grade: str
    packaging: str
    active: bool

    model_config = {"from_attributes": True}


class ListingActiveIn(BaseModel):
    active: bool


def _serialize_listing(listing: Listing, db: Session) -> ListingOut:
    shop = db.get(Shop, listing.seller_id)
    profile = db.get(Profile, listing.seller_id)
    seller_name = (shop.shop_name if shop else "") or (profile.name if profile else "") or "Seller"
    return ListingOut(
        id=listing.id,
        seller_id=listing.seller_id,
        seller_name=seller_name,
        seller_logo_url=shop.logo_url if shop else "",
        seller_verified=bool(profile and profile.verification_status == "verified"),
        seller_location=shop.location if shop else "",
        product_name=listing.product_name,
        category=listing.category,
        price=listing.price,
        moq_qty=listing.moq_qty,
        stock_qty=listing.stock_qty,
        description=listing.description,
        sample_testing_enabled=listing.sample_testing_enabled,
        sample_price=listing.sample_price,
        photo_urls=listing.photo_urls,
        sizes=listing.sizes,
        colors=[ColorOptionOut(**c) for c in listing.colors],
        weight=listing.weight,
        origin=listing.origin,
        grade=listing.grade,
        packaging=listing.packaging,
        active=listing.active,
    )


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

    urls = []
    for photo in photos:
        filename = save_image_as_webp(photo, PHOTOS_DIR, seller_id)
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
    weight: str = Form(""),
    origin: str = Form(""),
    grade: str = Form(""),
    packaging: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ListingOut:
    require_verified_seller(user, db)

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
        weight=weight.strip(),
        origin=origin.strip(),
        grade=grade.strip(),
        packaging=packaging.strip(),
    )
    db.add(listing)
    db.commit()
    db.refresh(listing)
    return _serialize_listing(listing, db)


@router.get("/me", response_model=list[ListingOut])
def list_my_listings(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[ListingOut]:
    listings = (
        db.query(Listing)
        .filter(Listing.seller_id == user.id)
        .order_by(Listing.created_at.desc())
        .all()
    )
    return [_serialize_listing(listing, db) for listing in listings]


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
    weight: str = Form(""),
    origin: str = Form(""),
    grade: str = Form(""),
    packaging: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ListingOut:
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
    listing.weight = weight.strip()
    listing.origin = origin.strip()
    listing.grade = grade.strip()
    listing.packaging = packaging.strip()
    db.commit()
    db.refresh(listing)
    return _serialize_listing(listing, db)


@router.patch("/me/{listing_id}/active", response_model=ListingOut)
def set_listing_active(
    listing_id: str,
    payload: ListingActiveIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ListingOut:
    listing = _get_owned_listing(db, user, listing_id)
    listing.active = payload.active
    db.commit()
    db.refresh(listing)
    return _serialize_listing(listing, db)


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
) -> list[ListingOut]:
    query = db.query(Listing).filter(Listing.active.is_(True))
    if category:
        query = query.filter(Listing.category == category)
    if seller_id:
        query = query.filter(Listing.seller_id == seller_id)
    if q:
        pattern = f"%{q.strip()}%"
        query = query.filter(
            or_(Listing.product_name.ilike(pattern), Listing.description.ilike(pattern))
        )
    listings = query.order_by(Listing.created_at.desc()).all()
    return [_serialize_listing(listing, db) for listing in listings]


@router.get("/{listing_id}", response_model=ListingOut)
def get_listing(listing_id: str, db: Session = Depends(get_db)) -> ListingOut:
    listing = db.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status_code=404, detail="Listing not found")
    return _serialize_listing(listing, db)
