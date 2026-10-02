from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Shop, StoreAddress

router = APIRouter(prefix="/shop/me/addresses", tags=["store-addresses"])

_SEED_LABEL = "Main Store"


class StoreAddressOut(BaseModel):
    id: str
    label: str
    store_name: str
    business_type: str
    full_address: str
    district: str
    province: str
    phone: str
    email: str
    operating_hours: str
    is_default: bool

    model_config = {"from_attributes": True}


class StoreAddressIn(BaseModel):
    label: str
    store_name: str
    business_type: str = ""
    full_address: str
    district: str = ""
    province: str
    phone: str
    email: str = ""
    operating_hours: str = ""
    is_default: bool = False


def _split_location(location: str) -> tuple[str, str, str]:
    """Unpacks the signup wizard's `street, Sangkat X, Khan Y, Province`
    string (see business_info_screen.dart) into (full_address, district,
    province). A single free-text part falls back to all-in-full_address."""
    parts = [p.strip() for p in location.split(",") if p.strip()]
    district_parts = [p for p in parts if p.startswith(("Sangkat ", "Khan "))]
    rest = [p for p in parts if p not in district_parts]
    if rest and (district_parts or len(rest) >= 2):
        province = rest.pop()
        return ", ".join(rest), ", ".join(district_parts), province
    return location.strip(), "", ""


def _seed_from_shop(db: Session, seller_id: str) -> None:
    """Creates the seller's first store address from what they entered at
    registration — once only: any existing row, even a deleted one, means the
    book was already seeded or used."""
    exists = db.scalar(
        select(StoreAddress.id).where(StoreAddress.seller_id == seller_id).limit(1)
    )
    if exists is not None:
        return
    shop = db.get(Shop, seller_id)
    if shop is None or not shop.location.strip():
        return
    full_address, district, province = _split_location(shop.location)
    db.add(
        StoreAddress(
            seller_id=seller_id,
            label=_SEED_LABEL,
            store_name=shop.shop_name,
            business_type=shop.business_type,
            full_address=full_address,
            district=district,
            province=province,
            phone=shop.phone,
            email=shop.email,
            is_default=True,
        )
    )
    db.commit()


def _live(db: Session, seller_id: str) -> list[StoreAddress]:
    return list(
        db.scalars(
            select(StoreAddress)
            .where(StoreAddress.seller_id == seller_id, StoreAddress.deleted.is_(False))
            .order_by(StoreAddress.created_at)
        )
    )


def _ensure_default(addresses: list[StoreAddress]) -> None:
    """Keeps exactly one address flagged default whenever the book is non-empty."""
    if addresses and not any(a.is_default for a in addresses):
        addresses[0].is_default = True


def _make_default(addresses: list[StoreAddress], address_id: str) -> None:
    for a in addresses:
        a.is_default = a.id == address_id


def _get_owned(db: Session, seller_id: str, address_id: str) -> StoreAddress:
    address = db.get(StoreAddress, address_id)
    if address is None or address.seller_id != seller_id or address.deleted:
        raise HTTPException(status_code=404, detail="Store address not found")
    return address


def _apply(address: StoreAddress, payload: StoreAddressIn) -> None:
    address.label = payload.label.strip()
    address.store_name = payload.store_name.strip()
    address.business_type = payload.business_type.strip()
    address.full_address = payload.full_address.strip()
    address.district = payload.district.strip()
    address.province = payload.province.strip()
    address.phone = payload.phone.strip()
    address.email = payload.email.strip()
    address.operating_hours = payload.operating_hours.strip()


@router.get("", response_model=list[StoreAddressOut])
def list_addresses(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[StoreAddress]:
    _seed_from_shop(db, user.id)
    return _live(db, user.id)


@router.post("", response_model=list[StoreAddressOut])
def add_address(
    payload: StoreAddressIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[StoreAddress]:
    address = StoreAddress(seller_id=user.id)
    _apply(address, payload)
    db.add(address)
    db.flush()
    addresses = _live(db, user.id)
    if payload.is_default:
        _make_default(addresses, address.id)
    _ensure_default(addresses)
    db.commit()
    return _live(db, user.id)


@router.put("/{address_id}", response_model=list[StoreAddressOut])
def update_address(
    address_id: str,
    payload: StoreAddressIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[StoreAddress]:
    address = _get_owned(db, user.id, address_id)
    _apply(address, payload)
    addresses = _live(db, user.id)
    if payload.is_default:
        _make_default(addresses, address.id)
    else:
        address.is_default = False
    _ensure_default(addresses)
    db.commit()
    return _live(db, user.id)


@router.delete("/{address_id}", response_model=list[StoreAddressOut])
def delete_address(
    address_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[StoreAddress]:
    address = _get_owned(db, user.id, address_id)
    address.deleted = True
    address.is_default = False
    db.flush()
    _ensure_default(_live(db, user.id))
    db.commit()
    return _live(db, user.id)


@router.post("/{address_id}/default", response_model=list[StoreAddressOut])
def set_default(
    address_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[StoreAddress]:
    _get_owned(db, user.id, address_id)
    _make_default(_live(db, user.id), address_id)
    db.commit()
    return _live(db, user.id)
