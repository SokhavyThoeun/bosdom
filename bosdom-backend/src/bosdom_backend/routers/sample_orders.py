from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Order, SampleOrder

router = APIRouter(prefix="/sample-orders", tags=["sample-orders"])

# 1-per-account cap resets 3 days after the buyer's most recent sample. Samples
# are now bought as paid escrow orders (`POST /orders` with `sample: true`).
SAMPLE_ORDER_COOLDOWN = timedelta(days=3)


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


def last_sample_at(db: Session, buyer_id: str) -> datetime | None:
    """When the buyer last got a sample: their latest paid sample order, or
    a sample requested before samples were paid for."""
    times = [
        o.paid_at
        for o in db.query(Order)
        .filter(
            Order.buyer_id == buyer_id,
            Order.is_sample.is_(True),
            Order.paid_at.is_not(None),
        )
        .all()
    ]
    legacy = _latest_sample_order(db, buyer_id)
    if legacy is not None:
        times.append(legacy.created_at)
    times = [t if t.tzinfo else t.replace(tzinfo=timezone.utc) for t in times if t]
    return max(times, default=None)


def sample_eligibility(db: Session, buyer_id: str) -> tuple[bool, datetime | None]:
    """(eligible, eligible_at) under the one-sample-per-3-days rule."""
    last = last_sample_at(db, buyer_id)
    if last is None:
        return True, None
    eligible_at = last + SAMPLE_ORDER_COOLDOWN
    if datetime.now(timezone.utc) >= eligible_at:
        return True, None
    return False, eligible_at


@router.get("/me/eligibility", response_model=SampleEligibilityOut)
def get_sample_eligibility(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> SampleEligibilityOut:
    last_order = _latest_sample_order(db, user.id)
    eligible, eligible_at = sample_eligibility(db, user.id)
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
