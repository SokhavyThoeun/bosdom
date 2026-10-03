from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import BuyerAddress

router = APIRouter(prefix="/profile/me/addresses", tags=["buyer-addresses"])


class BuyerAddressOut(BaseModel):
    id: str
    label: str
    house_number: str
    sangkat: str
    province: str
    phone: str
    landmark: str | None
    district: str | None
    sangkat_name: str | None
    is_default: bool

    model_config = {"from_attributes": True}


class BuyerAddressIn(BaseModel):
    label: str
    house_number: str = ""
    sangkat: str = ""
    province: str
    phone: str = ""
    landmark: str | None = None
    district: str | None = None
    sangkat_name: str | None = None
    is_default: bool = False


def _live(db: Session, user_id: str) -> list[BuyerAddress]:
    return list(
        db.scalars(
            select(BuyerAddress)
            .where(BuyerAddress.user_id == user_id)
            .order_by(BuyerAddress.created_at)
        )
    )


def _ensure_default(addresses: list[BuyerAddress]) -> None:
    """Keeps exactly one address flagged default whenever the book is non-empty."""
    if addresses and not any(a.is_default for a in addresses):
        addresses[0].is_default = True


def _make_default(addresses: list[BuyerAddress], address_id: str) -> None:
    for a in addresses:
        a.is_default = a.id == address_id


def _get_owned(db: Session, user_id: str, address_id: str) -> BuyerAddress:
    address = db.get(BuyerAddress, address_id)
    if address is None or address.user_id != user_id:
        raise HTTPException(status_code=404, detail="Address not found")
    return address


def _optional(value: str | None) -> str | None:
    value = (value or "").strip()
    return value or None


def _apply(address: BuyerAddress, payload: BuyerAddressIn) -> None:
    address.label = payload.label.strip()
    address.house_number = payload.house_number.strip()
    address.sangkat = payload.sangkat.strip()
    address.province = payload.province.strip()
    address.phone = payload.phone.strip()
    address.landmark = _optional(payload.landmark)
    address.district = _optional(payload.district)
    address.sangkat_name = _optional(payload.sangkat_name)


@router.get("", response_model=list[BuyerAddressOut])
def list_addresses(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[BuyerAddress]:
    return _live(db, user.id)


@router.post("", response_model=list[BuyerAddressOut])
def add_address(
    payload: BuyerAddressIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[BuyerAddress]:
    address = BuyerAddress(user_id=user.id)
    _apply(address, payload)
    db.add(address)
    db.flush()
    addresses = _live(db, user.id)
    if payload.is_default:
        _make_default(addresses, address.id)
    _ensure_default(addresses)
    db.commit()
    return _live(db, user.id)


@router.put("/{address_id}", response_model=list[BuyerAddressOut])
def update_address(
    address_id: str,
    payload: BuyerAddressIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[BuyerAddress]:
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


@router.delete("/{address_id}", response_model=list[BuyerAddressOut])
def delete_address(
    address_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[BuyerAddress]:
    db.delete(_get_owned(db, user.id, address_id))
    db.flush()
    _ensure_default(_live(db, user.id))
    db.commit()
    return _live(db, user.id)


@router.post("/{address_id}/default", response_model=list[BuyerAddressOut])
def set_default(
    address_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[BuyerAddress]:
    _get_owned(db, user.id, address_id)
    _make_default(_live(db, user.id), address_id)
    db.commit()
    return _live(db, user.id)
