from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Listing, SampleOrder

router = APIRouter(prefix="/sample-orders", tags=["sample-orders"])

# 1-per-account cap resets 3 days after the buyer's most recent sample order.
SAMPLE_ORDER_COOLDOWN = timedelta(days=3)


class SampleOrderCreate(BaseModel):
    listing_id: str


class SampleOrderOut(BaseModel):
    id: str
    listing_id: str
    seller_id: str
    product_name: str
    price: float
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class SampleEligibilityOut(BaseModel):
    eligible: bool
    eligible_at: datetime | None
    last_sample_order: SampleOrderOut | None


def _latest_sample_order(db: Session, buyer_id: str) -> SampleOrder | None:
    return (
        db.query(SampleOrder)
        .filter(SampleOrder.buyer_id == buyer_id)
        .order_by(SampleOrder.created_at.desc())
        .first()
    )


def _eligibility(last_order: SampleOrder | None) -> tuple[bool, datetime | None]:
    if last_order is None:
        return True, None
    last_created_at = last_order.created_at
    if last_created_at.tzinfo is None:
        last_created_at = last_created_at.replace(tzinfo=timezone.utc)
    eligible_at = last_created_at + SAMPLE_ORDER_COOLDOWN
    if datetime.now(timezone.utc) >= eligible_at:
        return True, None
    return False, eligible_at


@router.get("/me/eligibility", response_model=SampleEligibilityOut)
def get_sample_eligibility(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> SampleEligibilityOut:
    last_order = _latest_sample_order(db, user.id)
    eligible, eligible_at = _eligibility(last_order)
    return SampleEligibilityOut(
        eligible=eligible, eligible_at=eligible_at, last_sample_order=last_order
    )


@router.get("/me", response_model=list[SampleOrderOut])
def list_my_sample_orders(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[SampleOrder]:
    return (
        db.query(SampleOrder)
        .filter(SampleOrder.buyer_id == user.id)
        .order_by(SampleOrder.created_at.desc())
        .all()
    )


@router.post("", response_model=SampleOrderOut)
def create_sample_order(
    payload: SampleOrderCreate,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SampleOrder:
    listing = db.get(Listing, payload.listing_id)
    if listing is None:
        raise HTTPException(status_code=404, detail="Listing not found")
    if not listing.sample_testing_enabled or listing.sample_price is None:
        raise HTTPException(
            status_code=400, detail="This listing does not offer sample testing"
        )

    last_order = _latest_sample_order(db, user.id)
    eligible, eligible_at = _eligibility(last_order)
    if not eligible:
        raise HTTPException(
            status_code=409,
            detail={
                "message": "Only one sample order is allowed every 3 days",
                "eligible_at": eligible_at.isoformat() if eligible_at else None,
            },
        )

    order = SampleOrder(
        buyer_id=user.id,
        listing_id=listing.id,
        seller_id=listing.seller_id,
        product_name=listing.product_name,
        price=listing.sample_price,
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order
