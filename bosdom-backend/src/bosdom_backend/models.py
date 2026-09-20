import uuid
from datetime import datetime, timezone

from sqlalchemy import JSON, Boolean, DateTime, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base


class Profile(Base):
    __tablename__ = "profiles"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    email: Mapped[str] = mapped_column(String, default="")
    name: Mapped[str] = mapped_column(String, default="")
    phone: Mapped[str] = mapped_column(String, default="")
    role: Mapped[str] = mapped_column(String, default="")
    avatar_url: Mapped[str] = mapped_column(String, default="")
    verification_status: Mapped[str] = mapped_column(String, default="unverified")
    onboarding_complete: Mapped[bool] = mapped_column(Boolean, default=False)
    is_suspended: Mapped[bool] = mapped_column(Boolean, default=False)
    chat_tos_accepted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    chat_flag_count: Mapped[int] = mapped_column(Integer, default=0)
    chat_restricted_until: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class KycDocument(Base):
    __tablename__ = "kyc_documents"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    profile_id: Mapped[str] = mapped_column(String, index=True)
    doc_type: Mapped[str] = mapped_column(String)
    file_url: Mapped[str] = mapped_column(String)
    uploaded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class Shop(Base):
    __tablename__ = "shops"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    shop_name: Mapped[str] = mapped_column(String, default="")
    business_type: Mapped[str] = mapped_column(String, default="")
    store_type: Mapped[str] = mapped_column(String, default="")
    year_established: Mapped[str] = mapped_column(String, default="")
    location: Mapped[str] = mapped_column(String, default="")
    phone: Mapped[str] = mapped_column(String, default="")
    email: Mapped[str] = mapped_column(String, default="")
    description: Mapped[str] = mapped_column(String, default="")
    store_url: Mapped[str] = mapped_column(String, default="")
    logo_url: Mapped[str] = mapped_column(String, default="")
    photo_urls: Mapped[list[str]] = mapped_column(JSON, default=list)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class Listing(Base):
    __tablename__ = "listings"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    seller_id: Mapped[str] = mapped_column(String, index=True)
    product_name: Mapped[str] = mapped_column(String)
    category: Mapped[str] = mapped_column(String)
    price: Mapped[float] = mapped_column(Float)
    moq_qty: Mapped[int] = mapped_column(Integer)
    stock_qty: Mapped[int] = mapped_column(Integer)
    description: Mapped[str] = mapped_column(String, default="")
    sample_testing_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    sample_price: Mapped[float | None] = mapped_column(Float, nullable=True)
    photo_urls: Mapped[list[str]] = mapped_column(JSON, default=list)
    sizes: Mapped[list[str]] = mapped_column(JSON, default=list)
    colors: Mapped[list[dict]] = mapped_column(JSON, default=list)
    weight: Mapped[str] = mapped_column(String, default="")
    origin: Mapped[str] = mapped_column(String, default="")
    grade: Mapped[str] = mapped_column(String, default="")
    packaging: Mapped[str] = mapped_column(String, default="")
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class CoBuyPool(Base):
    # Table is `co_buy_deal_pools`, not `co_buy_pools` — the live DB already
    # has an unrelated legacy `co_buy_pools` table this backend doesn't own,
    # same reasoning as `Order`'s `escrow_orders` table name (see its notes).
    __tablename__ = "co_buy_deal_pools"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    seller_id: Mapped[str] = mapped_column(String, index=True)
    product_name: Mapped[str] = mapped_column(String)
    description: Mapped[str] = mapped_column(String, default="")
    price: Mapped[float] = mapped_column(Float)
    original_price: Mapped[float] = mapped_column(Float)
    target_qty: Mapped[int] = mapped_column(Integer)
    unit_label: Mapped[str] = mapped_column(String)
    per_unit_label: Mapped[str] = mapped_column(String)
    min_order_qty: Mapped[int] = mapped_column(Integer)
    time_left: Mapped[str] = mapped_column(String)
    auto_renew: Mapped[bool] = mapped_column(Boolean, default=False)
    photo_urls: Mapped[list[str]] = mapped_column(JSON, default=list)
    sizes: Mapped[list[str]] = mapped_column(JSON, default=list)
    colors: Mapped[list[dict]] = mapped_column(JSON, default=list)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class CoBuyParticipant(Base):
    # Table is `co_buy_deal_participants`, not `co_buy_participants` — same
    # legacy-table-name collision reasoning as `CoBuyPool` above.
    __tablename__ = "co_buy_deal_participants"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    pool_id: Mapped[str] = mapped_column(String, index=True)
    buyer_id: Mapped[str] = mapped_column(String, index=True)
    quantity: Mapped[int] = mapped_column(Integer)
    size: Mapped[str | None] = mapped_column(String, nullable=True)
    color_name: Mapped[str | None] = mapped_column(String, nullable=True)
    color_hex: Mapped[str | None] = mapped_column(String, nullable=True)
    # Escrow state machine, mirroring `Order`'s (see its notes):
    # pending_payment -> held -> released
    #                          \-> leave_requested -> refunded (admin approves)
    #                                              \-> held (admin rejects)
    # Only paid rows (held/leave_requested/released) count toward the pool.
    status: Mapped[str] = mapped_column(String, default="pending_payment")
    payment_method: Mapped[str | None] = mapped_column(String, nullable=True)
    payment_reference: Mapped[str | None] = mapped_column(String, nullable=True)
    joined_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    paid_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    leave_requested_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    released_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    refunded_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    # Why the buyer asked to leave, and the admin's decision on it.
    leave_reason: Mapped[str | None] = mapped_column(String, nullable=True)
    leave_admin_note: Mapped[str | None] = mapped_column(String, nullable=True)
    leave_resolved_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )


class SampleOrder(Base):
    __tablename__ = "sample_orders"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    buyer_id: Mapped[str] = mapped_column(String, index=True)
    listing_id: Mapped[str] = mapped_column(String, index=True)
    seller_id: Mapped[str] = mapped_column(String, index=True)
    product_name: Mapped[str] = mapped_column(String)
    price: Mapped[float] = mapped_column(Float)
    status: Mapped[str] = mapped_column(String, default="processing")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class Order(Base):
    # Table is `escrow_orders`, not `orders` — the live DB already has a
    # legacy, unrelated `orders` table from `supabase/migrations/*.sql` that
    # this backend doesn't own (see the Phase 9/10 migration notes).
    __tablename__ = "escrow_orders"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    buyer_id: Mapped[str] = mapped_column(String, index=True)
    seller_id: Mapped[str] = mapped_column(String, index=True)
    listing_id: Mapped[str] = mapped_column(String, index=True)
    product_name: Mapped[str] = mapped_column(String)
    unit_price: Mapped[float] = mapped_column(Float)
    quantity: Mapped[int] = mapped_column(Integer)
    total_amount: Mapped[float] = mapped_column(Float)
    shipping_name: Mapped[str] = mapped_column(String, default="")
    shipping_address: Mapped[str] = mapped_column(String, default="")
    shipping_phone: Mapped[str] = mapped_column(String, default="")
    # Escrow state machine: pending_payment -> held -> released
    #                                       \-> cancelled   held -> disputed -> released/refunded
    status: Mapped[str] = mapped_column(String, default="pending_payment")
    payment_method: Mapped[str | None] = mapped_column(String, nullable=True)
    payment_reference: Mapped[str | None] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
    paid_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    # Seller acknowledging they've seen/accepted a held order — not a status
    # transition, just a flag the buyer can see while the order stays `held`.
    seller_confirmed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    released_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    # Seller asking the admin to release the held funds early — the admin
    # panel's payout queue is `held` orders with this set.
    release_requested_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    cancelled_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    refunded_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    # Seller withdrawing a released order's earnings to their bank: set on
    # every released order swept up by one `POST /orders/request-payout`.
    # That is only a request: it waits for the admin to approve it, which
    # sets `payout_eta_at`. The money "arrives" once that passes.
    payout_requested_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    payout_eta_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    payout_bank_name: Mapped[str | None] = mapped_column(String, nullable=True)
    payout_account_holder: Mapped[str | None] = mapped_column(String, nullable=True)
    payout_account_number: Mapped[str | None] = mapped_column(String, nullable=True)
    # Fulfilment proof: the seller ships with a parcel photo + tracking
    # number, then uploads proof of delivery, which starts the buyer's
    # review-window timer (`review_deadline_at`). Still `held` throughout.
    shipped_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    courier: Mapped[str | None] = mapped_column(String, nullable=True)
    tracking_number: Mapped[str | None] = mapped_column(String, nullable=True)
    shipping_photo_url: Mapped[str | None] = mapped_column(String, nullable=True)
    delivered_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    delivery_proof_url: Mapped[str | None] = mapped_column(String, nullable=True)
    # When the timer ends and funds auto-release. Frozen (nulled, with the
    # time left saved in `review_remaining_seconds`) if the buyer reports a
    # problem.
    review_deadline_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    review_remaining_seconds: Mapped[int | None] = mapped_column(
        Integer, nullable=True
    )
    # Set on release: the platform's cut and what the seller is owed.
    platform_fee: Mapped[float | None] = mapped_column(Float, nullable=True)
    seller_amount: Mapped[float | None] = mapped_column(Float, nullable=True)
    auto_released: Mapped[bool] = mapped_column(Boolean, default=False)


class Dispute(Base):
    __tablename__ = "disputes"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    order_id: Mapped[str] = mapped_column(String, index=True)
    raised_by: Mapped[str] = mapped_column(String, index=True)
    reason: Mapped[str] = mapped_column(String)
    note: Mapped[str] = mapped_column(String, default="")
    # evidence_window -> under_review (video submitted) -> resolved
    # (release or refund, decided by the counterparty per 15.5's
    # resolve endpoint — see routers/disputes.py for why there's no
    # separate admin role making this call).
    status: Mapped[str] = mapped_column(String, default="evidence_window")
    evidence_deadline: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    resolution: Mapped[str | None] = mapped_column(String, nullable=True)
    resolved_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    # Admin-run case: the admin opens it, the seller and the courier each
    # reply, then the admin decides who is at fault (seller/courier/buyer).
    case_opened_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    seller_response: Mapped[str | None] = mapped_column(String, nullable=True)
    seller_responded_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    courier_response: Mapped[str | None] = mapped_column(String, nullable=True)
    courier_responded_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    fault: Mapped[str | None] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class SellerReport(Base):
    __tablename__ = "seller_reports"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    order_id: Mapped[str] = mapped_column(String, index=True)
    seller_id: Mapped[str] = mapped_column(String, index=True)
    reason: Mapped[str] = mapped_column(String)
    note: Mapped[str] = mapped_column(String, default="")
    photo_urls: Mapped[list[str]] = mapped_column(JSON, default=list)
    # open -> refund_pending (admin cancelled the order, refund scheduled)
    # -> resolved. A report can also go straight open -> resolved (dismissed).
    status: Mapped[str] = mapped_column(String, default="open")
    # When a scheduled refund to the buyer becomes due (refund_pending only).
    refund_due_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    # dismissed | refunded — how the report was closed.
    resolution: Mapped[str | None] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class DisputeEvidence(Base):
    __tablename__ = "dispute_evidence"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    dispute_id: Mapped[str] = mapped_column(String, index=True)
    file_url: Mapped[str] = mapped_column(String)
    uploaded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class Conversation(Base):
    __tablename__ = "conversations"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    buyer_id: Mapped[str] = mapped_column(String, index=True)
    seller_id: Mapped[str] = mapped_column(String, index=True)
    listing_id: Mapped[str | None] = mapped_column(String, nullable=True)
    buyer_last_read_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    seller_last_read_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class Message(Base):
    __tablename__ = "messages"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    conversation_id: Mapped[str] = mapped_column(String, index=True)
    sender_id: Mapped[str] = mapped_column(String, index=True)
    text: Mapped[str | None] = mapped_column(String, nullable=True)
    image_url: Mapped[str | None] = mapped_column(String, nullable=True)
    flagged: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class OrderReport(Base):
    __tablename__ = "order_reports"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    order_id: Mapped[str] = mapped_column(String, index=True)
    reason: Mapped[str] = mapped_column(String)
    note: Mapped[str] = mapped_column(String, default="")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class OrderReview(Base):
    __tablename__ = "order_reviews"

    id: Mapped[str] = mapped_column(
        String, primary_key=True, default=lambda: str(uuid.uuid4())
    )
    # One review per order — a buyer can only rate/review a released order
    # once (resubmitting edits the existing row instead of creating a new
    # one, see submit_order_review in routers/orders.py).
    order_id: Mapped[str] = mapped_column(String, unique=True, index=True)
    buyer_id: Mapped[str] = mapped_column(String, index=True)
    rating: Mapped[int] = mapped_column(Integer)
    comment: Mapped[str] = mapped_column(String, default="")
    photo_urls: Mapped[list[str]] = mapped_column(JSON, default=list)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
