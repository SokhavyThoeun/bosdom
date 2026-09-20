import random
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..admin_auth import create_admin_token, get_current_admin
from ..config import settings
from ..db import get_db
from ..models import (
    CoBuyParticipant,
    CoBuyPool,
    SellerReport,
    Conversation,
    Dispute,
    DisputeEvidence,
    KycDocument,
    Listing,
    Message,
    Order,
    Profile,
    Shop,
)
from ..utils.images import save_image_as_webp
from .chat import (
    CHAT_IMAGES_DIR,
    MessageOut,
    SUPPORT_AGENT_ID,
    get_or_create_support_conversation,
)
from .disputes import (
    DISPUTE_STATUS_CASE_OPEN,
    DISPUTE_STATUS_RESOLVED,
    VALID_FAULTS,
    settle_dispute,
)
from .orders import (
    fee_rate_for,
    COURIER_REFUND_DELAY,
    auto_release_due_orders,
    freeze_order,
    refund_order,
    seller_amount_for,
)

router = APIRouter(prefix="/admin", tags=["admin"])

_admin_only = [Depends(get_current_admin)]


class AdminLoginRequest(BaseModel):
    email: str
    password: str


class AdminLoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


@router.post("/auth/login", response_model=AdminLoginResponse)
def admin_login(payload: AdminLoginRequest) -> AdminLoginResponse:
    if (
        payload.email != settings.admin_email
        or payload.password != settings.admin_password
    ):
        raise HTTPException(status_code=401, detail="Invalid admin credentials")
    return AdminLoginResponse(access_token=create_admin_token())


class AdminStats(BaseModel):
    seller_count: int
    buyer_count: int
    listing_count: int
    order_count: int
    pending_disputes: int
    pending_kyc: int


@router.get("/stats", response_model=AdminStats, dependencies=_admin_only)
def get_stats(db: Session = Depends(get_db)) -> AdminStats:
    return AdminStats(
        seller_count=db.query(Profile).filter(Profile.role == "supplier").count(),
        buyer_count=db.query(Profile).filter(Profile.role != "supplier").count(),
        listing_count=db.query(Listing).count(),
        order_count=db.query(Order).count(),
        pending_disputes=db.query(Dispute)
        .filter(Dispute.status != "resolved")
        .count(),
        pending_kyc=db.query(Profile)
        .filter(Profile.verification_status == "pending")
        .count(),
    )


class AdminKycDocOut(BaseModel):
    doc_type: str
    file_url: str


class AdminSellerOut(BaseModel):
    id: str
    name: str
    email: str
    phone: str
    verification_status: str
    is_suspended: bool
    created_at: datetime
    shop_name: str
    shop_business_type: str
    shop_store_type: str
    shop_year_established: str
    shop_location: str
    shop_phone: str
    shop_email: str
    shop_description: str
    shop_store_url: str
    shop_logo_url: str
    shop_photo_urls: list[str]
    kyc_documents: list[AdminKycDocOut]


@router.get("/sellers", response_model=list[AdminSellerOut], dependencies=_admin_only)
def list_sellers(db: Session = Depends(get_db)) -> list[AdminSellerOut]:
    profiles = (
        db.query(Profile)
        .filter(Profile.role == "supplier")
        .order_by(Profile.created_at.desc())
        .all()
    )
    if not profiles:
        return []

    # `profiles.id` is a native Postgres UUID column while every other
    # table's id/foreign-key columns are varchar/text (see the 2026-09-18
    # admin panel notes in CHECKPOINT.md) — always coerce a `Profile.id` to
    # `str` before using it as a filter value or dict key against them,
    # or Postgres rejects the comparison / the lookup silently misses.
    ids = [str(p.id) for p in profiles]
    shops = {s.id: s for s in db.query(Shop).filter(Shop.id.in_(ids)).all()}
    kyc_by_profile: dict[str, list[AdminKycDocOut]] = {}
    for row in db.query(KycDocument).filter(KycDocument.profile_id.in_(ids)).all():
        kyc_by_profile.setdefault(row.profile_id, []).append(
            AdminKycDocOut(doc_type=row.doc_type, file_url=row.file_url)
        )

    result = []
    for p in profiles:
        pid = str(p.id)
        shop = shops.get(pid)
        result.append(
            AdminSellerOut(
                id=pid,
                name=p.name,
                email=p.email,
                phone=p.phone,
                verification_status=p.verification_status,
                is_suspended=p.is_suspended,
                created_at=p.created_at,
                shop_name=shop.shop_name if shop else "",
                shop_business_type=shop.business_type if shop else "",
                shop_store_type=shop.store_type if shop else "",
                shop_year_established=shop.year_established if shop else "",
                shop_location=shop.location if shop else "",
                shop_phone=shop.phone if shop else "",
                shop_email=shop.email if shop else "",
                shop_description=shop.description if shop else "",
                shop_store_url=shop.store_url if shop else "",
                shop_logo_url=shop.logo_url if shop else "",
                shop_photo_urls=shop.photo_urls if shop else [],
                kyc_documents=kyc_by_profile.get(pid, []),
            )
        )
    return result


class AdminUserOut(BaseModel):
    id: str
    name: str
    email: str
    phone: str
    role: str
    verification_status: str
    is_suspended: bool
    created_at: datetime


def _user_out(profile: Profile) -> AdminUserOut:
    return AdminUserOut(
        id=str(profile.id),
        name=profile.name,
        email=profile.email,
        phone=profile.phone,
        role=profile.role,
        verification_status=profile.verification_status,
        is_suspended=profile.is_suspended,
        created_at=profile.created_at,
    )


@router.get("/users", response_model=list[AdminUserOut], dependencies=_admin_only)
def list_users(db: Session = Depends(get_db)) -> list[AdminUserOut]:
    profiles = (
        db.query(Profile)
        .filter(Profile.role != "supplier")
        .order_by(Profile.created_at.desc())
        .all()
    )
    return [_user_out(p) for p in profiles]


def _get_profile_or_404(db: Session, profile_id: str) -> Profile:
    profile = db.get(Profile, profile_id)
    if profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile


@router.post(
    "/profiles/{profile_id}/verify",
    response_model=AdminUserOut,
    dependencies=_admin_only,
)
def verify_profile(profile_id: str, db: Session = Depends(get_db)) -> AdminUserOut:
    profile = _get_profile_or_404(db, profile_id)
    profile.verification_status = "verified"
    db.commit()
    db.refresh(profile)
    return _user_out(profile)


@router.post(
    "/profiles/{profile_id}/reject",
    response_model=AdminUserOut,
    dependencies=_admin_only,
)
def reject_profile(profile_id: str, db: Session = Depends(get_db)) -> AdminUserOut:
    """Denies a pending KYC submission. The seller stays "rejected" until
    they re-upload their national ID, which resets them to "pending" for
    another review (see upload_kyc_document in routers/profile.py)."""
    profile = _get_profile_or_404(db, profile_id)
    profile.verification_status = "rejected"
    db.commit()
    db.refresh(profile)
    return _user_out(profile)


@router.post(
    "/profiles/{profile_id}/unverify",
    response_model=AdminUserOut,
    dependencies=_admin_only,
)
def unverify_profile(profile_id: str, db: Session = Depends(get_db)) -> AdminUserOut:
    """Revokes a previously granted verification, e.g. after fraud is found
    later. Distinct from `reject`, which denies a pending submission."""
    profile = _get_profile_or_404(db, profile_id)
    profile.verification_status = "unverified"
    db.commit()
    db.refresh(profile)
    return _user_out(profile)


@router.post(
    "/profiles/{profile_id}/suspend",
    response_model=AdminUserOut,
    dependencies=_admin_only,
)
def suspend_profile(profile_id: str, db: Session = Depends(get_db)) -> AdminUserOut:
    profile = _get_profile_or_404(db, profile_id)
    profile.is_suspended = True
    db.commit()
    db.refresh(profile)
    return _user_out(profile)


@router.post(
    "/profiles/{profile_id}/unsuspend",
    response_model=AdminUserOut,
    dependencies=_admin_only,
)
def unsuspend_profile(profile_id: str, db: Session = Depends(get_db)) -> AdminUserOut:
    profile = _get_profile_or_404(db, profile_id)
    profile.is_suspended = False
    db.commit()
    db.refresh(profile)
    return _user_out(profile)


class AdminListingOut(BaseModel):
    id: str
    seller_id: str
    seller_name: str
    product_name: str
    category: str
    price: float
    stock_qty: int
    active: bool
    created_at: datetime
    photo_urls: list[str]


@router.get("/listings", response_model=list[AdminListingOut], dependencies=_admin_only)
def list_all_listings(db: Session = Depends(get_db)) -> list[AdminListingOut]:
    listings = db.query(Listing).order_by(Listing.created_at.desc()).all()
    if not listings:
        return []

    seller_ids = {listing.seller_id for listing in listings}
    profiles = {
        str(p.id): p
        for p in db.query(Profile).filter(Profile.id.in_(seller_ids)).all()
    }
    shops = {s.id: s for s in db.query(Shop).filter(Shop.id.in_(seller_ids)).all()}

    def seller_name(seller_id: str) -> str:
        shop = shops.get(seller_id)
        profile = profiles.get(seller_id)
        return (
            (shop.shop_name if shop else "")
            or (profile.name if profile else "")
            or "Seller"
        )

    return [
        AdminListingOut(
            id=listing.id,
            seller_id=listing.seller_id,
            seller_name=seller_name(listing.seller_id),
            product_name=listing.product_name,
            category=listing.category,
            price=listing.price,
            stock_qty=listing.stock_qty,
            active=listing.active,
            created_at=listing.created_at,
            photo_urls=listing.photo_urls,
        )
        for listing in listings
    ]


def _get_listing_or_404(db: Session, listing_id: str) -> Listing:
    listing = db.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status_code=404, detail="Listing not found")
    return listing


@router.post("/listings/{listing_id}/takedown", dependencies=_admin_only)
def takedown_listing(listing_id: str, db: Session = Depends(get_db)) -> dict[str, bool]:
    listing = _get_listing_or_404(db, listing_id)
    listing.active = False
    db.commit()
    return {"active": listing.active}


@router.post("/listings/{listing_id}/restore", dependencies=_admin_only)
def restore_listing(listing_id: str, db: Session = Depends(get_db)) -> dict[str, bool]:
    listing = _get_listing_or_404(db, listing_id)
    listing.active = True
    db.commit()
    return {"active": listing.active}


class AdminOrderOut(BaseModel):
    id: str
    buyer_id: str
    buyer_name: str
    seller_id: str
    seller_name: str
    product_name: str
    total_amount: float
    status: str
    created_at: datetime
    # Where the order is in the release flow.
    shipped_at: datetime | None = None
    courier: str | None = None
    tracking_number: str | None = None
    delivered_at: datetime | None = None
    review_deadline_at: datetime | None = None
    review_remaining_seconds: int | None = None
    platform_fee: float | None = None
    seller_amount: float | None = None
    auto_released: bool = False


@router.get("/orders", response_model=list[AdminOrderOut], dependencies=_admin_only)
def list_all_orders(db: Session = Depends(get_db)) -> list[AdminOrderOut]:
    auto_release_due_orders(db)
    orders = db.query(Order).order_by(Order.created_at.desc()).all()
    if not orders:
        return []

    person_ids = {o.buyer_id for o in orders} | {o.seller_id for o in orders}
    profiles = {
        str(p.id): p
        for p in db.query(Profile).filter(Profile.id.in_(person_ids)).all()
    }
    shops = {s.id: s for s in db.query(Shop).filter(Shop.id.in_(person_ids)).all()}

    def name_for(person_id: str, prefer_shop: bool) -> str:
        profile = profiles.get(person_id)
        shop = shops.get(person_id) if prefer_shop else None
        return (
            (shop.shop_name if shop else "")
            or (profile.name if profile else "")
            or "Unknown"
        )

    return [
        AdminOrderOut(
            id=o.id,
            buyer_id=o.buyer_id,
            buyer_name=name_for(o.buyer_id, prefer_shop=False),
            seller_id=o.seller_id,
            seller_name=name_for(o.seller_id, prefer_shop=True),
            product_name=o.product_name,
            total_amount=o.total_amount,
            status=o.status,
            created_at=o.created_at,
            shipped_at=o.shipped_at,
            courier=o.courier,
            tracking_number=o.tracking_number,
            delivered_at=o.delivered_at,
            review_deadline_at=o.review_deadline_at,
            review_remaining_seconds=o.review_remaining_seconds,
            platform_fee=o.platform_fee,
            seller_amount=o.seller_amount,
            auto_released=o.auto_released,
        )
        for o in orders
    ]

# How long an approved payout takes to reach the seller's bank (mocked).
_PAYOUT_DELAYS_HOURS = (1, 3)


class AdminPayoutRequestOut(BaseModel):
    order_id: str
    seller_id: str
    seller_name: str
    buyer_name: str
    product_name: str
    total_amount: float
    payout_amount: float
    # "pending" until the admin approves the seller's withdrawal, then
    # "approved" (money on its way to the bank below).
    status: str
    requested_at: datetime
    released_at: datetime | None
    bank_name: str | None
    account_holder: str | None
    account_number: str | None


@router.get(
    "/payout-requests",
    response_model=list[AdminPayoutRequestOut],
    dependencies=_admin_only,
)
def list_payout_requests(db: Session = Depends(get_db)) -> list[AdminPayoutRequestOut]:
    auto_release_due_orders(db)
    orders = (
        db.query(Order)
        .filter(Order.payout_requested_at.is_not(None))
        .order_by(Order.payout_requested_at.desc())
        .all()
    )
    if not orders:
        return []
    return _payout_requests_out(db, orders)


def _payout_requests_out(
    db: Session, orders: list[Order]
) -> list[AdminPayoutRequestOut]:
    person_ids = {o.buyer_id for o in orders} | {o.seller_id for o in orders}
    profiles = {
        str(p.id): p
        for p in db.query(Profile).filter(Profile.id.in_(person_ids)).all()
    }
    shops = {s.id: s for s in db.query(Shop).filter(Shop.id.in_(person_ids)).all()}

    def name_for(person_id: str, prefer_shop: bool) -> str:
        profile = profiles.get(person_id)
        shop = shops.get(person_id) if prefer_shop else None
        return (
            (shop.shop_name if shop else "")
            or (profile.name if profile else "")
            or "Unknown"
        )

    return [
        AdminPayoutRequestOut(
            order_id=o.id,
            seller_id=o.seller_id,
            seller_name=name_for(o.seller_id, prefer_shop=True),
            buyer_name=name_for(o.buyer_id, prefer_shop=False),
            product_name=o.product_name,
            total_amount=o.total_amount,
            payout_amount=seller_amount_for(o),
            status="pending" if o.payout_eta_at is None else "approved",
            requested_at=o.payout_requested_at,
            released_at=o.released_at,
            bank_name=o.payout_bank_name,
            account_holder=o.payout_account_holder,
            account_number=o.payout_account_number,
        )
        for o in orders
    ]


@router.post(
    "/payout-requests/{order_id}/release",
    response_model=AdminPayoutRequestOut,
    dependencies=_admin_only,
)
def approve_payout_request(
    order_id: str, db: Session = Depends(get_db)
) -> AdminPayoutRequestOut:
    """Approve a seller's withdrawal request: the money is now on its way to
    their bank and lands 1 to 3 hours later."""
    order = db.get(Order, order_id)
    if order is None or order.payout_requested_at is None:
        raise HTTPException(status_code=404, detail="Payout request not found")
    if order.payout_eta_at is not None:
        raise HTTPException(status_code=409, detail="Payout already approved")
    order.payout_eta_at = datetime.now(timezone.utc) + timedelta(
        hours=random.choice(_PAYOUT_DELAYS_HOURS)
    )
    db.commit()
    db.refresh(order)
    return _payout_requests_out(db, [order])[0]


class AdminDisputeOut(BaseModel):
    id: str
    order_id: str
    raised_by: str
    reason: str
    note: str
    status: str
    resolution: str | None
    created_at: datetime
    order_product_name: str
    order_total_amount: float
    buyer_name: str = ""
    seller_name: str = ""
    case_opened_at: datetime | None = None
    seller_response: str | None = None
    courier_response: str | None = None
    fault: str | None = None
    courier: str | None = None
    tracking_number: str | None = None
    shipping_photo_url: str | None = None
    delivery_proof_url: str | None = None
    # Time left on the (frozen) review timer when the problem was reported.
    frozen_seconds_left: int | None = None
    evidence_urls: list[str] = []
    # What each side would get if the admin decides one way or the other.
    seller_payout: float = 0.0
    platform_fee: float = 0.0


def _dispute_out(db: Session, dispute: Dispute) -> AdminDisputeOut:
    order = db.get(Order, dispute.order_id)
    evidence = (
        db.query(DisputeEvidence)
        .filter(DisputeEvidence.dispute_id == dispute.id)
        .order_by(DisputeEvidence.uploaded_at)
        .all()
    )
    people = {}
    shop = None
    if order is not None:
        ids = {order.buyer_id, order.seller_id}
        people = {
            str(p.id): p for p in db.query(Profile).filter(Profile.id.in_(ids)).all()
        }
        shop = db.get(Shop, order.seller_id)
    buyer = people.get(order.buyer_id) if order else None
    seller = people.get(order.seller_id) if order else None
    fee = (
        (
            order.platform_fee
            if order.platform_fee is not None
            else round(
                order.total_amount
                * fee_rate_for(db, order.seller_id, datetime.now(timezone.utc)),
                2,
            )
        )
        if order
        else 0.0
    )
    return AdminDisputeOut(
        id=dispute.id,
        order_id=dispute.order_id,
        raised_by=dispute.raised_by,
        reason=dispute.reason,
        note=dispute.note,
        status=dispute.status,
        resolution=dispute.resolution,
        created_at=dispute.created_at,
        order_product_name=order.product_name if order else "",
        order_total_amount=order.total_amount if order else 0.0,
        buyer_name=(buyer.name if buyer else "") or "Unknown",
        seller_name=((shop.shop_name if shop else "") or (seller.name if seller else "")) or "Unknown",
        case_opened_at=dispute.case_opened_at,
        seller_response=dispute.seller_response,
        courier_response=dispute.courier_response,
        fault=dispute.fault,
        courier=order.courier if order else None,
        tracking_number=order.tracking_number if order else None,
        shipping_photo_url=order.shipping_photo_url if order else None,
        delivery_proof_url=order.delivery_proof_url if order else None,
        frozen_seconds_left=order.review_remaining_seconds if order else None,
        evidence_urls=[e.file_url for e in evidence],
        seller_payout=round(order.total_amount - fee, 2) if order else 0.0,
        platform_fee=fee,
    )


@router.get("/disputes", response_model=list[AdminDisputeOut], dependencies=_admin_only)
def list_all_disputes(db: Session = Depends(get_db)) -> list[AdminDisputeOut]:
    disputes = db.query(Dispute).order_by(Dispute.created_at.desc()).all()
    return [_dispute_out(db, d) for d in disputes]


def _get_dispute_or_404(db: Session, dispute_id: str) -> Dispute:
    dispute = db.get(Dispute, dispute_id)
    if dispute is None:
        raise HTTPException(status_code=404, detail="Dispute not found")
    return dispute


@router.post(
    "/disputes/{dispute_id}/open-case",
    response_model=AdminDisputeOut,
    dependencies=_admin_only,
)
def open_case(dispute_id: str, db: Session = Depends(get_db)) -> AdminDisputeOut:
    """Admin picks up a reported problem: the seller is asked to reply and
    the admin records the courier's reply before deciding."""
    dispute = _get_dispute_or_404(db, dispute_id)
    if dispute.status == DISPUTE_STATUS_RESOLVED:
        raise HTTPException(status_code=409, detail="Dispute already resolved")
    if dispute.status == DISPUTE_STATUS_CASE_OPEN:
        raise HTTPException(status_code=409, detail="Case already open")
    dispute.status = DISPUTE_STATUS_CASE_OPEN
    dispute.case_opened_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(dispute)
    return _dispute_out(db, dispute)


class AdminCourierReplyRequest(BaseModel):
    text: str


@router.post(
    "/disputes/{dispute_id}/courier-reply",
    response_model=AdminDisputeOut,
    dependencies=_admin_only,
)
def record_courier_reply(
    dispute_id: str,
    payload: AdminCourierReplyRequest,
    db: Session = Depends(get_db),
) -> AdminDisputeOut:
    """Couriers don't have accounts here, so the admin records what the
    courier said when contacted about the parcel."""
    dispute = _get_dispute_or_404(db, dispute_id)
    if dispute.status != DISPUTE_STATUS_CASE_OPEN:
        raise HTTPException(status_code=409, detail="Open the case first")
    text = payload.text.strip()
    if not text:
        raise HTTPException(status_code=422, detail="Reply can't be empty")
    dispute.courier_response = text
    dispute.courier_responded_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(dispute)
    return _dispute_out(db, dispute)


class AdminDisputeResolveRequest(BaseModel):
    resolution: str
    fault: str = "none"


@router.post(
    "/disputes/{dispute_id}/resolve",
    response_model=AdminDisputeOut,
    dependencies=_admin_only,
)
def admin_resolve_dispute(
    dispute_id: str,
    payload: AdminDisputeResolveRequest,
    db: Session = Depends(get_db),
) -> AdminDisputeOut:
    """The admin's decision — who is at fault. `refund` sends the money back
    to the buyer; `release` pays the seller (platform fee taken)."""
    dispute = _get_dispute_or_404(db, dispute_id)
    if payload.resolution not in {"release", "refund"}:
        raise HTTPException(
            status_code=400, detail="Resolution must be 'release' or 'refund'"
        )
    if payload.fault not in VALID_FAULTS:
        raise HTTPException(status_code=400, detail="Unknown fault")
    if dispute.status == DISPUTE_STATUS_RESOLVED:
        raise HTTPException(status_code=409, detail="Dispute already resolved")
    if dispute.status != DISPUTE_STATUS_CASE_OPEN:
        raise HTTPException(status_code=409, detail="Open the case first")

    settle_dispute(db, dispute, payload.resolution, payload.fault)
    db.commit()
    db.refresh(dispute)
    return _dispute_out(db, dispute)


class AdminSupportConversationOut(BaseModel):
    id: str
    user_id: str
    user_name: str
    user_email: str
    user_role: str
    unread_count: int
    last_message_preview: str
    last_message_at: datetime | None


class AdminSupportConversationDetailOut(BaseModel):
    conversation: AdminSupportConversationOut
    messages: list[MessageOut]


class AdminSupportReplyRequest(BaseModel):
    text: str


def _support_conversation_or_404(db: Session, conversation_id: str) -> Conversation:
    conversation = db.get(Conversation, conversation_id)
    if conversation is None or conversation.seller_id != SUPPORT_AGENT_ID:
        raise HTTPException(status_code=404, detail="Support conversation not found")
    return conversation


def _support_conversation_out(
    db: Session, conversation: Conversation
) -> AdminSupportConversationOut:
    profile = db.get(Profile, conversation.buyer_id)
    last_message = (
        db.query(Message)
        .filter(Message.conversation_id == conversation.id)
        .order_by(Message.created_at.desc())
        .first()
    )
    # "Unread" for the admin = user messages newer than the last time an
    # admin opened/replied to the thread (stored in the support side's
    # `seller_last_read_at`).
    unread_query = db.query(Message).filter(
        Message.conversation_id == conversation.id,
        Message.sender_id != SUPPORT_AGENT_ID,
    )
    if conversation.seller_last_read_at is not None:
        unread_query = unread_query.filter(
            Message.created_at > conversation.seller_last_read_at
        )

    preview = ""
    if last_message is not None:
        preview = last_message.text or ("📷 Photo" if last_message.image_url else "")
    return AdminSupportConversationOut(
        id=conversation.id,
        user_id=conversation.buyer_id,
        user_name=(profile.name if profile else "") or "BosDom User",
        user_email=profile.email if profile else "",
        user_role=profile.role if profile else "",
        unread_count=unread_query.count(),
        last_message_preview=preview,
        last_message_at=last_message.created_at if last_message else None,
    )


@router.get(
    "/support/conversations",
    response_model=list[AdminSupportConversationOut],
    dependencies=_admin_only,
)
def list_support_conversations(
    db: Session = Depends(get_db),
) -> list[AdminSupportConversationOut]:
    conversations = (
        db.query(Conversation).filter(Conversation.seller_id == SUPPORT_AGENT_ID).all()
    )
    result = [_support_conversation_out(db, c) for c in conversations]
    result.sort(
        key=lambda c: c.last_message_at or datetime.min.replace(tzinfo=timezone.utc),
        reverse=True,
    )
    return result


class AdminStartSupportRequest(BaseModel):
    user_id: str


@router.post(
    "/support/conversations",
    response_model=AdminSupportConversationOut,
    dependencies=_admin_only,
)
def start_support_conversation(
    payload: AdminStartSupportRequest, db: Session = Depends(get_db)
) -> AdminSupportConversationOut:
    """Get-or-create the support thread with a given user, so an admin can
    reach out first (e.g. to confirm something about their account)."""
    if db.get(Profile, payload.user_id) is None:
        raise HTTPException(status_code=404, detail="User not found")
    conversation = get_or_create_support_conversation(db, payload.user_id)
    return _support_conversation_out(db, conversation)


@router.get(
    "/support/conversations/{conversation_id}",
    response_model=AdminSupportConversationDetailOut,
    dependencies=_admin_only,
)
def get_support_conversation(
    conversation_id: str, db: Session = Depends(get_db)
) -> AdminSupportConversationDetailOut:
    conversation = _support_conversation_or_404(db, conversation_id)
    messages = (
        db.query(Message)
        .filter(Message.conversation_id == conversation.id)
        .order_by(Message.created_at.asc())
        .all()
    )
    detail = AdminSupportConversationDetailOut(
        conversation=_support_conversation_out(db, conversation),
        messages=messages,
    )
    conversation.seller_last_read_at = datetime.now(timezone.utc)
    db.commit()
    detail.conversation.unread_count = 0
    return detail


@router.post(
    "/support/conversations/{conversation_id}/reply",
    response_model=MessageOut,
    dependencies=_admin_only,
)
def reply_to_support_conversation(
    conversation_id: str,
    payload: AdminSupportReplyRequest,
    db: Session = Depends(get_db),
) -> Message:
    conversation = _support_conversation_or_404(db, conversation_id)
    text = payload.text.strip()
    if not text:
        raise HTTPException(status_code=422, detail="Reply text is required")

    message = Message(
        conversation_id=conversation.id, sender_id=SUPPORT_AGENT_ID, text=text
    )
    db.add(message)
    conversation.seller_last_read_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(message)
    return message


@router.post(
    "/support/conversations/{conversation_id}/reply-image",
    response_model=MessageOut,
    dependencies=_admin_only,
)
def reply_to_support_conversation_with_image(
    conversation_id: str,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
) -> Message:
    conversation = _support_conversation_or_404(db, conversation_id)
    filename = save_image_as_webp(file, CHAT_IMAGES_DIR, conversation.id)

    message = Message(
        conversation_id=conversation.id,
        sender_id=SUPPORT_AGENT_ID,
        image_url=f"/media/chat_images/{filename}",
    )
    db.add(message)
    conversation.seller_last_read_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(message)
    return message


class AdminSellerReportOut(BaseModel):
    id: str
    order_id: str
    seller_id: str
    seller_name: str
    buyer_id: str
    buyer_name: str
    product_name: str
    reason: str
    note: str
    photo_urls: list[str]
    status: str
    order_status: str
    refund_due_at: datetime | None
    resolution: str | None
    created_at: datetime


@router.get(
    "/seller-reports",
    response_model=list[AdminSellerReportOut],
    dependencies=_admin_only,
)
def list_seller_reports(db: Session = Depends(get_db)) -> list[AdminSellerReportOut]:
    auto_release_due_orders(db)
    reports = db.query(SellerReport).order_by(SellerReport.created_at.desc()).all()
    out = []
    for r in reports:
        seller = db.get(Profile, r.seller_id)
        order = db.get(Order, r.order_id)
        buyer = db.get(Profile, order.buyer_id) if order else None
        out.append(
            AdminSellerReportOut(
                id=r.id,
                order_id=r.order_id,
                seller_id=r.seller_id,
                seller_name=seller.name if seller else "",
                buyer_id=order.buyer_id if order else "",
                buyer_name=buyer.name if buyer else "",
                product_name=order.product_name if order else "",
                reason=r.reason,
                note=r.note,
                photo_urls=r.photo_urls or [],
                status=r.status,
                order_status=order.status if order else "",
                refund_due_at=r.refund_due_at,
                resolution=r.resolution,
                created_at=r.created_at,
            )
        )
    return out


@router.post("/seller-reports/{report_id}/resolve", dependencies=_admin_only)
def resolve_seller_report(
    report_id: str, db: Session = Depends(get_db)
) -> dict[str, bool]:
    report = db.get(SellerReport, report_id)
    if report is None:
        raise HTTPException(status_code=404, detail="Report not found")
    if report.status == "resolved":
        raise HTTPException(status_code=409, detail="Report already resolved")
    if report.status == "refund_pending":
        raise HTTPException(
            status_code=409, detail="A refund is pending for this report"
        )
    report.status = "resolved"
    report.resolution = "dismissed"
    db.commit()
    return {"ok": True}


class AdminSellerReportRefundRequest(BaseModel):
    # True = send the money back right away; False = hold it for
    # COURIER_REFUND_DELAY first.
    immediate: bool = False


@router.post("/seller-reports/{report_id}/refund-buyer", dependencies=_admin_only)
def refund_buyer_for_seller_report(
    report_id: str,
    payload: AdminSellerReportRefundRequest,
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """The courier confirmed the parcel was lost/damaged: cancel the order
    and return the buyer's money — after a short hold, or right now."""
    auto_release_due_orders(db)
    report = db.get(SellerReport, report_id)
    if report is None:
        raise HTTPException(status_code=404, detail="Report not found")
    if report.status == "resolved":
        raise HTTPException(status_code=409, detail="Report already resolved")
    order = db.get(Order, report.order_id)
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status not in ("held", "disputed"):
        raise HTTPException(
            status_code=409,
            detail=f"Cannot refund a '{order.status}' order",
        )
    now = datetime.now(timezone.utc)
    if payload.immediate:
        refund_order(db, order, now)
        report.status = "resolved"
        report.resolution = "refunded"
        report.refund_due_at = None
    else:
        freeze_order(order, now)
        report.status = "refund_pending"
        if report.refund_due_at is None:
            report.refund_due_at = now + COURIER_REFUND_DELAY
    db.commit()
    return {"status": report.status}


class AdminCoBuyLeaveOut(BaseModel):
    id: str
    pool_id: str
    product_name: str
    seller_name: str
    buyer_name: str
    quantity: int
    amount: float
    payment_method: str | None
    reason: str
    requested_at: datetime
    # "pending" | "approved" (refunded) | "rejected" (buyer stays in the deal)
    decision: str
    admin_note: str | None
    resolved_at: datetime | None


def _co_buy_leaves_out(
    db: Session, rows: list[CoBuyParticipant]
) -> list[AdminCoBuyLeaveOut]:
    pools = {
        p.id: p
        for p in db.query(CoBuyPool)
        .filter(CoBuyPool.id.in_({r.pool_id for r in rows}))
        .all()
    }
    person_ids = {r.buyer_id for r in rows} | {p.seller_id for p in pools.values()}
    profiles = {
        str(p.id): p
        for p in db.query(Profile).filter(Profile.id.in_(person_ids)).all()
    }
    shops = {s.id: s for s in db.query(Shop).filter(Shop.id.in_(person_ids)).all()}

    out = []
    for r in rows:
        pool = pools.get(r.pool_id)
        if pool is None:
            continue
        seller_shop = shops.get(pool.seller_id)
        seller_profile = profiles.get(pool.seller_id)
        buyer = profiles.get(r.buyer_id)
        out.append(
            AdminCoBuyLeaveOut(
                id=r.id,
                pool_id=r.pool_id,
                product_name=pool.product_name,
                seller_name=(seller_shop.shop_name if seller_shop else "")
                or (seller_profile.name if seller_profile else "")
                or "Unknown",
                buyer_name=(buyer.name if buyer else "") or "Unknown",
                quantity=r.quantity,
                amount=round(pool.price * r.quantity, 2),
                payment_method=r.payment_method,
                reason=r.leave_reason or "",
                requested_at=r.leave_requested_at,
                decision={"leave_requested": "pending", "refunded": "approved"}.get(
                    r.status, "rejected"
                ),
                admin_note=r.leave_admin_note,
                resolved_at=r.leave_resolved_at or r.refunded_at,
            )
        )
    return out


@router.get(
    "/co-buy-leave-requests",
    response_model=list[AdminCoBuyLeaveOut],
    dependencies=_admin_only,
)
def list_co_buy_leave_requests(
    db: Session = Depends(get_db),
) -> list[AdminCoBuyLeaveOut]:
    rows = (
        db.query(CoBuyParticipant)
        .filter(CoBuyParticipant.leave_requested_at.is_not(None))
        .order_by(CoBuyParticipant.leave_requested_at.desc())
        .all()
    )
    return _co_buy_leaves_out(db, rows) if rows else []


def _pending_leave_or_error(db: Session, participant_id: str) -> CoBuyParticipant:
    row = db.get(CoBuyParticipant, participant_id)
    if row is None or row.leave_requested_at is None:
        raise HTTPException(status_code=404, detail="Leave request not found")
    if row.status != "leave_requested":
        raise HTTPException(status_code=409, detail="Already decided")
    return row


@router.post(
    "/co-buy-leave-requests/{participant_id}/approve",
    response_model=AdminCoBuyLeaveOut,
    dependencies=_admin_only,
)
def approve_co_buy_leave(
    participant_id: str, db: Session = Depends(get_db)
) -> AdminCoBuyLeaveOut:
    """Approve: the buyer's escrowed payment is refunded and they're out of
    the deal (freeing their quantity for others)."""
    row = _pending_leave_or_error(db, participant_id)
    now = datetime.now(timezone.utc)
    row.status = "refunded"
    row.refunded_at = now
    row.leave_resolved_at = now
    db.commit()
    return _co_buy_leaves_out(db, [row])[0]


class AdminCoBuyLeaveRejectRequest(BaseModel):
    note: str = ""


@router.post(
    "/co-buy-leave-requests/{participant_id}/reject",
    response_model=AdminCoBuyLeaveOut,
    dependencies=_admin_only,
)
def reject_co_buy_leave(
    participant_id: str,
    body: AdminCoBuyLeaveRejectRequest,
    db: Session = Depends(get_db),
) -> AdminCoBuyLeaveOut:
    """Reject: the buyer stays in the deal with their payment still held."""
    row = _pending_leave_or_error(db, participant_id)
    row.status = "held"
    row.leave_admin_note = body.note.strip() or None
    row.leave_resolved_at = datetime.now(timezone.utc)
    db.commit()
    return _co_buy_leaves_out(db, [row])[0]
