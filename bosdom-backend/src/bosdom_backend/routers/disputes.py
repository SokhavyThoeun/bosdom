import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Dispute, DisputeEvidence, Order
from .orders import STATUS_DISPUTED, _get_participant_order, _transition

router = APIRouter(tags=["disputes"])

EVIDENCE_DIR = Path(__file__).resolve().parent.parent / "media" / "dispute_evidence"
_ALLOWED_EVIDENCE_TYPES = {
    "video/mp4": ".mp4",
    "video/quicktime": ".mov",
    "video/webm": ".webm",
}
# How long a buyer has, after opening a dispute, to upload video evidence
# before the window closes. Arbitrary-but-reasonable (the checkpoint asked
# for "time-window enforcement" without specifying a duration) — matches the
# precedent set by 12.1's sample-order cooldown and 14.4's chat restriction.
EVIDENCE_WINDOW = timedelta(hours=48)

DISPUTE_STATUS_EVIDENCE_WINDOW = "evidence_window"
DISPUTE_STATUS_UNDER_REVIEW = "under_review"


def _aware(dt: datetime) -> datetime:
    """SQLite (used by the test harness) returns tz-naive datetimes even for
    DateTime(timezone=True) columns that are tz-aware on the real Postgres
    backend — same landmine as 12.1's eligibility check."""
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=timezone.utc)


def _get_dispute_for_participant(db: Session, dispute_id: str, user_id: str) -> Dispute:
    dispute = db.get(Dispute, dispute_id)
    if dispute is None:
        raise HTTPException(status_code=404, detail="Dispute not found")
    order = db.get(Order, dispute.order_id)
    if order is None or user_id not in (order.buyer_id, order.seller_id):
        # 404, not 403 — matches the ownership-hiding pattern used elsewhere
        # (listings/chat/orders) so a non-participant can't confirm it exists.
        raise HTTPException(status_code=404, detail="Dispute not found")
    return dispute


class DisputeCreate(BaseModel):
    reason: str
    note: str = ""


class DisputeOut(BaseModel):
    id: str
    order_id: str
    raised_by: str
    reason: str
    note: str
    status: str
    evidence_deadline: datetime
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class DisputeEvidenceOut(BaseModel):
    id: str
    dispute_id: str
    file_url: str
    uploaded_at: datetime

    model_config = {"from_attributes": True}


@router.post("/orders/{order_id}/dispute", response_model=DisputeOut)
def open_dispute(
    order_id: str,
    payload: DisputeCreate,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Dispute:
    """Buyer-initiated escrow dispute (15.4): moves the order from `held`
    into `disputed` (only reachable from `held`, enforced by `_transition`)
    and opens a time-limited window to upload video evidence. Resolving a
    dispute (release vs. refund) is Phase 15.5, not this endpoint."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.buyer_id:
        raise HTTPException(status_code=403, detail="Only the buyer can open a dispute")

    existing = db.query(Dispute).filter(Dispute.order_id == order_id).one_or_none()
    if existing is not None:
        raise HTTPException(status_code=409, detail="A dispute already exists for this order")

    _transition(order, STATUS_DISPUTED)

    dispute = Dispute(
        order_id=order.id,
        raised_by=user.id,
        reason=payload.reason,
        note=payload.note,
        evidence_deadline=datetime.now(timezone.utc) + EVIDENCE_WINDOW,
    )
    db.add(dispute)
    db.commit()
    db.refresh(dispute)
    return dispute


@router.get("/orders/{order_id}/dispute", response_model=DisputeOut)
def get_order_dispute(
    order_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Dispute:
    order = _get_participant_order(db, order_id, user.id)
    dispute = db.query(Dispute).filter(Dispute.order_id == order.id).one_or_none()
    if dispute is None:
        raise HTTPException(status_code=404, detail="No dispute for this order")
    return dispute


@router.get("/disputes/{dispute_id}/evidence", response_model=list[DisputeEvidenceOut])
def list_evidence(
    dispute_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[DisputeEvidence]:
    _get_dispute_for_participant(db, dispute_id, user.id)
    return (
        db.query(DisputeEvidence)
        .filter(DisputeEvidence.dispute_id == dispute_id)
        .order_by(DisputeEvidence.uploaded_at)
        .all()
    )


@router.post("/disputes/{dispute_id}/evidence", response_model=DisputeEvidenceOut)
def upload_evidence(
    dispute_id: str,
    file: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DisputeEvidence:
    dispute = _get_dispute_for_participant(db, dispute_id, user.id)
    if user.id != dispute.raised_by:
        raise HTTPException(
            status_code=403, detail="Only the dispute's raiser can upload evidence"
        )
    if datetime.now(timezone.utc) > _aware(dispute.evidence_deadline):
        raise HTTPException(status_code=409, detail="Evidence upload window has closed")

    ext = _ALLOWED_EVIDENCE_TYPES.get(file.content_type or "")
    if ext is None:
        raise HTTPException(status_code=400, detail="Unsupported video type")

    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)
    filename = f"{dispute.id}-{uuid.uuid4().hex[:8]}{ext}"
    with (EVIDENCE_DIR / filename).open("wb") as out:
        out.write(file.file.read())

    evidence = DisputeEvidence(
        dispute_id=dispute.id, file_url=f"/media/dispute_evidence/{filename}"
    )
    db.add(evidence)
    dispute.status = DISPUTE_STATUS_UNDER_REVIEW
    db.commit()
    db.refresh(evidence)
    return evidence
