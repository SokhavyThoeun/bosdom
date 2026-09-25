import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from .. import storage
from ..utils.images import save_image_as_webp
from .notifications import NotificationTarget, push_notification
from ..models import Dispute, DisputeEvidence, Order, SellerReport
from .orders import (
    STATUS_DISPUTED,
    STATUS_REFUNDED,
    STATUS_RELEASED,
    _aware,
    _get_participant_order,
    _transition,
    auto_release_due_orders,
    fee_rate_for,
    release_funds,
)

router = APIRouter(tags=["disputes"])

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
# The admin has opened a case: seller and courier are asked to reply, then
# the admin decides.
DISPUTE_STATUS_CASE_OPEN = "case_open"
DISPUTE_STATUS_RESOLVED = "resolved"

RESOLUTION_RELEASE = "release"
RESOLUTION_REFUND = "refund"
_VALID_RESOLUTIONS = {RESOLUTION_RELEASE, RESOLUTION_REFUND}
VALID_FAULTS = {"seller", "courier", "buyer", "none"}


def settle_dispute(
    db: Session, dispute: Dispute, resolution: str, fault: str | None
) -> Order:
    """Drives the order to released (fee taken, seller paid) or refunded and
    closes the dispute. Shared by the seller's refund and the admin's decision."""
    order = db.get(Order, dispute.order_id)
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    now = datetime.now(timezone.utc)
    if resolution == RESOLUTION_RELEASE:
        release_funds(order, now, fee_rate=fee_rate_for(db, order.seller_id, now))
    else:
        _transition(order, STATUS_REFUNDED)
        order.refunded_at = now
        order.review_remaining_seconds = None
    dispute.status = DISPUTE_STATUS_RESOLVED
    dispute.resolution = resolution
    dispute.fault = fault
    dispute.resolved_at = now
    return order


def notify_dispute_settled(db: Session, dispute: Dispute, order: Order) -> None:
    """Tells both sides how a dispute ended. Call after the commit."""
    released = dispute.resolution == RESOLUTION_RELEASE
    push_notification(
        db,
        order.buyer_id,
        "order",
        "Dispute resolved",
        f"Your dispute for {order.product_name} ended: "
        + ("funds were released to the seller." if released else "you were refunded."),
        NotificationTarget(route="orderDetail", params={"id": order.id}),
    )
    push_notification(
        db,
        order.seller_id,
        "order",
        "Dispute resolved",
        f"The dispute for {order.product_name} ended: "
        + ("funds were released to you." if released else "the buyer was refunded."),
        NotificationTarget(route="sellerOrderDetail", params={"id": order.id}),
    )


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
    resolution: str | None
    resolved_at: datetime | None
    case_opened_at: datetime | None
    seller_response: str | None
    seller_responded_at: datetime | None
    courier_response: str | None
    courier_responded_at: datetime | None
    fault: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class DisputeResolveRequest(BaseModel):
    resolution: str


class SellerReplyRequest(BaseModel):
    text: str


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

    auto_release_due_orders(db)
    db.refresh(order)
    if order.status != "held":
        raise HTTPException(
            status_code=409,
            detail="The review window has closed. Funds were already released"
            if order.status == STATUS_RELEASED
            else f"Cannot report a problem on a '{order.status}' order",
        )
    _transition(order, STATUS_DISPUTED)
    # Freeze the review timer: remember how long was left, and stop it so it
    # can't auto-release while the case is open.
    if order.review_deadline_at is not None:
        remaining = _aware(order.review_deadline_at) - datetime.now(timezone.utc)
        order.review_remaining_seconds = max(0, int(remaining.total_seconds()))
        order.review_deadline_at = None

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

    filename = f"{dispute.id}-{uuid.uuid4().hex[:8]}{ext}"
    file_url = storage.upload_private(
        f"dispute_evidence/{filename}", file.file.read(), file.content_type or ""
    )

    evidence = DisputeEvidence(dispute_id=dispute.id, file_url=file_url)
    db.add(evidence)
    dispute.status = DISPUTE_STATUS_UNDER_REVIEW
    db.commit()
    db.refresh(evidence)
    return evidence


@router.post("/disputes/{dispute_id}/resolve", response_model=DisputeOut)
def resolve_dispute(
    dispute_id: str,
    payload: DisputeResolveRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Dispute:
    """Settles a dispute (15.5) by driving the order to `released` (funds go
    to the seller) or `refunded` (funds go back to the buyer). There's no
    admin/support role anywhere in this backend (nothing checks `Profile.role`
    — see the 10.1/11.2 notes), so the counterparty who did *not* raise the
    dispute makes the call — today that's always the seller, since 15.4
    restricts opening a dispute to the buyer. This mirrors a seller responding
    to a buyer's claim on a real marketplace before it would otherwise
    escalate to a human reviewer."""
    dispute = _get_dispute_for_participant(db, dispute_id, user.id)
    if user.id == dispute.raised_by:
        raise HTTPException(
            status_code=403, detail="The dispute's raiser cannot resolve it"
        )
    if payload.resolution != RESOLUTION_REFUND:
        # Only the admin can decide a dispute in the seller's favour; the
        # seller can only concede and refund the buyer.
        raise HTTPException(
            status_code=403, detail="Only an admin can release funds on a dispute"
        )
    if dispute.status == DISPUTE_STATUS_RESOLVED:
        raise HTTPException(status_code=409, detail="Dispute already resolved")

    order = settle_dispute(db, dispute, RESOLUTION_REFUND, fault="seller")
    db.commit()
    db.refresh(dispute)
    notify_dispute_settled(db, dispute, order)
    return dispute


@router.post("/disputes/{dispute_id}/seller-reply", response_model=DisputeOut)
def seller_reply(
    dispute_id: str,
    payload: SellerReplyRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Dispute:
    """The seller's side of the story, once the admin has opened the case."""
    dispute = _get_dispute_for_participant(db, dispute_id, user.id)
    order = db.get(Order, dispute.order_id)
    if order is None or user.id != order.seller_id:
        raise HTTPException(status_code=403, detail="Only the seller can reply")
    if dispute.status != DISPUTE_STATUS_CASE_OPEN:
        raise HTTPException(status_code=409, detail="The case is not open for replies")
    text = payload.text.strip()
    if not text:
        raise HTTPException(status_code=422, detail="Reply can't be empty")
    dispute.seller_response = text
    dispute.seller_responded_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(dispute)
    return dispute


_MAX_SELLER_REPORT_PHOTOS = 3


class SellerReportOut(BaseModel):
    id: str
    order_id: str
    reason: str
    note: str
    photo_urls: list[str]
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


@router.post("/orders/{order_id}/seller-report", response_model=SellerReportOut)
def report_as_seller(
    order_id: str,
    reason: str = Form(...),
    note: str = Form(""),
    photos: list[UploadFile] = File(default_factory=list),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SellerReport:
    """The seller flags a delivery problem (delay, lost parcel, ...) so an
    admin can look into it and update the buyer. Doesn't touch the order's
    status or funds."""
    order = _get_participant_order(db, order_id, user.id)
    if user.id != order.seller_id:
        raise HTTPException(status_code=403, detail="Only the seller can report here")
    if len(photos) > _MAX_SELLER_REPORT_PHOTOS:
        raise HTTPException(
            status_code=400,
            detail=f"Up to {_MAX_SELLER_REPORT_PHOTOS} photos are allowed",
        )
    photo_urls = [
        save_image_as_webp(photo, "seller_report_photos", user.id) for photo in photos
    ]
    report = SellerReport(
        order_id=order.id,
        seller_id=user.id,
        reason=reason,
        note=note.strip(),
        photo_urls=photo_urls,
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report
