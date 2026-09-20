from datetime import datetime, timedelta, timezone
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy import or_
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import Conversation, Listing, Message, Profile, Shop
from ..off_platform import detects_off_platform_attempt
from ..utils.images import save_image_as_webp
from .notifications import NotificationTarget, push_notification

router = APIRouter(prefix="/chat", tags=["chat"])

# After this many off-platform-flagged messages, the sender is temporarily
# blocked from sending further messages.
FLAG_RESTRICTION_THRESHOLD = 3
FLAG_RESTRICTION_DURATION = timedelta(hours=24)

CHAT_IMAGES_DIR = Path(__file__).resolve().parent.parent / "media" / "chat_images"

# Reserved seller-side id for the "BosDom Support" inbox. A support thread is
# an ordinary Conversation (buyer_id = the user, seller_id = this), so the
# regular message/read/image endpoints and Supabase Realtime work unchanged.
# Admins reply from the admin panel (routers/admin.py), not as this "user".
SUPPORT_AGENT_ID = "bosdom-support"
SUPPORT_AGENT_NAME = "BosDom Support"
SUPPORT_GREETING = (
    "Hi! You're chatting with the BosDom Support team. Tell us how we can "
    "help. We're available Mon-Fri, 8 AM - 6 PM (Cambodia Time)."
)


class MessageOut(BaseModel):
    id: str
    sender_id: str
    text: str | None
    image_url: str | None = None
    flagged: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class ConversationSummaryOut(BaseModel):
    id: str
    counterpart_id: str
    counterpart_name: str
    counterpart_avatar_url: str | None
    counterpart_verified: bool
    listing_id: str | None
    unread_count: int
    last_message_preview: str
    last_message_at: datetime | None
    is_seller: bool


class ConversationOut(BaseModel):
    id: str
    counterpart_id: str
    counterpart_name: str
    counterpart_avatar_url: str | None
    counterpart_verified: bool
    listing_id: str | None
    is_seller: bool
    messages: list[MessageOut]


class StartConversationRequest(BaseModel):
    counterpart_id: str
    listing_id: str | None = None


class SendMessageRequest(BaseModel):
    text: str


class MarkReadOut(BaseModel):
    unread_count: int


class TosStatusOut(BaseModel):
    accepted: bool
    accepted_at: datetime | None


def _get_conversation_or_404(db: Session, conversation_id: str, user_id: str) -> Conversation:
    conversation = db.get(Conversation, conversation_id)
    if conversation is None or user_id not in (conversation.buyer_id, conversation.seller_id):
        raise HTTPException(status_code=404, detail="Conversation not found")
    return conversation


def _counterpart_id(conversation: Conversation, user_id: str) -> str:
    return conversation.seller_id if user_id == conversation.buyer_id else conversation.buyer_id


def _display_for(
    db: Session, conversation: Conversation, participant_id: str
) -> tuple[str, str | None, bool]:
    """Buyers see the seller's shop profile; sellers see the buyer's real profile."""
    if participant_id == SUPPORT_AGENT_ID:
        return SUPPORT_AGENT_NAME, None, True
    profile = db.get(Profile, participant_id)
    verified = profile.verification_status == "verified" if profile else False
    if participant_id == conversation.seller_id:
        shop = db.get(Shop, participant_id)
        name = (shop.shop_name if shop else "") or (profile.name if profile else "") or "BosDom User"
        avatar_url = shop.logo_url if shop and shop.logo_url else None
        return name, avatar_url, verified
    name = (profile.name if profile else "") or "BosDom User"
    avatar_url = profile.avatar_url if profile and profile.avatar_url else None
    return name, avatar_url, verified


def _last_read_at(conversation: Conversation, user_id: str) -> datetime | None:
    return (
        conversation.buyer_last_read_at
        if user_id == conversation.buyer_id
        else conversation.seller_last_read_at
    )


def _to_summary(db: Session, conversation: Conversation, user_id: str) -> ConversationSummaryOut:
    counterpart_id = _counterpart_id(conversation, user_id)
    name, avatar_url, verified = _display_for(db, conversation, counterpart_id)

    last_message = (
        db.query(Message)
        .filter(Message.conversation_id == conversation.id)
        .order_by(Message.created_at.desc())
        .first()
    )
    last_read_at = _last_read_at(conversation, user_id)
    unread_query = db.query(Message).filter(
        Message.conversation_id == conversation.id,
        Message.sender_id != user_id,
    )
    if last_read_at is not None:
        unread_query = unread_query.filter(Message.created_at > last_read_at)
    unread_count = unread_query.count()

    return ConversationSummaryOut(
        id=conversation.id,
        counterpart_id=counterpart_id,
        counterpart_name=name,
        counterpart_avatar_url=avatar_url,
        counterpart_verified=verified,
        listing_id=conversation.listing_id,
        unread_count=unread_count,
        last_message_preview=_message_preview(last_message),
        last_message_at=last_message.created_at if last_message else None,
        is_seller=user_id == conversation.seller_id,
    )


def _message_preview(message: Message | None) -> str:
    if message is None:
        return ""
    if message.text:
        return message.text
    if message.image_url:
        return "📷 Photo"
    return ""


@router.post("/conversations", response_model=ConversationSummaryOut)
def start_conversation(
    body: StartConversationRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ConversationSummaryOut:
    if body.counterpart_id == user.id:
        raise HTTPException(status_code=400, detail="Cannot start a conversation with yourself")

    if body.listing_id is not None:
        listing = db.get(Listing, body.listing_id)
        if listing is None:
            raise HTTPException(status_code=404, detail="Listing not found")
        if listing.seller_id != body.counterpart_id:
            raise HTTPException(status_code=400, detail="Listing does not belong to counterpart")

    existing = (
        db.query(Conversation)
        .filter(
            Conversation.buyer_id == user.id,
            Conversation.seller_id == body.counterpart_id,
        )
        .first()
    )
    if existing is None:
        existing = Conversation(
            buyer_id=user.id, seller_id=body.counterpart_id, listing_id=body.listing_id
        )
        db.add(existing)
        db.commit()
        db.refresh(existing)

    return _to_summary(db, existing, user.id)


def get_or_create_support_conversation(db: Session, user_id: str) -> Conversation:
    """The user's single thread with the BosDom Support team."""
    conversation = (
        db.query(Conversation)
        .filter(
            Conversation.buyer_id == user_id,
            Conversation.seller_id == SUPPORT_AGENT_ID,
        )
        .first()
    )
    if conversation is None:
        conversation = Conversation(buyer_id=user_id, seller_id=SUPPORT_AGENT_ID)
        db.add(conversation)
        db.flush()
        db.add(
            Message(
                conversation_id=conversation.id,
                sender_id=SUPPORT_AGENT_ID,
                text=SUPPORT_GREETING,
            )
        )
        db.commit()
        db.refresh(conversation)
    return conversation


@router.post("/support", response_model=ConversationSummaryOut)
def open_support_conversation(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> ConversationSummaryOut:
    """Get-or-create the caller's single thread with the BosDom Support team."""
    return _to_summary(db, get_or_create_support_conversation(db, user.id), user.id)


@router.get("/conversations", response_model=list[ConversationSummaryOut])
def list_conversations(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[ConversationSummaryOut]:
    # The support thread lives in the Help & Support > Live Chat screen, not
    # the buyer/seller inbox.
    conversations = (
        db.query(Conversation)
        .filter(
            or_(Conversation.buyer_id == user.id, Conversation.seller_id == user.id),
            Conversation.seller_id != SUPPORT_AGENT_ID,
        )
        .all()
    )
    summaries = [_to_summary(db, c, user.id) for c in conversations]
    summaries.sort(
        key=lambda s: s.last_message_at or datetime.min.replace(tzinfo=timezone.utc),
        reverse=True,
    )
    return summaries


@router.get("/conversations/{conversation_id}", response_model=ConversationOut)
def get_conversation(
    conversation_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ConversationOut:
    conversation = _get_conversation_or_404(db, conversation_id, user.id)
    counterpart_id = _counterpart_id(conversation, user.id)
    name, avatar_url, verified = _display_for(db, conversation, counterpart_id)
    messages = (
        db.query(Message)
        .filter(Message.conversation_id == conversation.id)
        .order_by(Message.created_at.asc())
        .all()
    )
    return ConversationOut(
        id=conversation.id,
        counterpart_id=counterpart_id,
        counterpart_name=name,
        counterpart_avatar_url=avatar_url,
        counterpart_verified=verified,
        listing_id=conversation.listing_id,
        is_seller=user.id == conversation.seller_id,
        messages=messages,
    )


@router.post("/conversations/{conversation_id}/read", response_model=MarkReadOut)
def mark_read(
    conversation_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MarkReadOut:
    conversation = _get_conversation_or_404(db, conversation_id, user.id)
    now = datetime.now(timezone.utc)
    if user.id == conversation.buyer_id:
        conversation.buyer_last_read_at = now
    else:
        conversation.seller_last_read_at = now
    db.commit()
    return MarkReadOut(unread_count=0)


@router.get("/tos/status", response_model=TosStatusOut)
def get_tos_status(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> TosStatusOut:
    profile = db.get(Profile, user.id)
    accepted_at = profile.chat_tos_accepted_at if profile else None
    return TosStatusOut(accepted=accepted_at is not None, accepted_at=accepted_at)


@router.post("/tos/accept", response_model=TosStatusOut)
def accept_tos(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> TosStatusOut:
    profile = db.get(Profile, user.id)
    if profile is None:
        profile = Profile(id=user.id, email=user.email or "", name=user.name or "")
        db.add(profile)
    profile.chat_tos_accepted_at = datetime.now(timezone.utc)
    db.commit()
    return TosStatusOut(accepted=True, accepted_at=profile.chat_tos_accepted_at)


def _flag_sender(db: Session, profile: Profile) -> None:
    profile.chat_flag_count += 1
    if profile.chat_flag_count >= FLAG_RESTRICTION_THRESHOLD:
        profile.chat_restricted_until = datetime.now(timezone.utc) + FLAG_RESTRICTION_DURATION
        profile.chat_flag_count = 0


def _require_can_send(db: Session, user: CurrentUser) -> Profile:
    profile = db.get(Profile, user.id)
    if profile is None or profile.chat_tos_accepted_at is None:
        raise HTTPException(
            status_code=403,
            detail={"code": "tos_not_accepted", "message": "Accept the chat & trading policy first"},
        )

    restricted_until = profile.chat_restricted_until
    if restricted_until is not None:
        if restricted_until.tzinfo is None:
            restricted_until = restricted_until.replace(tzinfo=timezone.utc)
        if datetime.now(timezone.utc) < restricted_until:
            raise HTTPException(
                status_code=403,
                detail={
                    "code": "chat_restricted",
                    "message": "You're temporarily restricted from sending messages due to repeated off-platform contact attempts",
                    "restricted_until": restricted_until.isoformat(),
                },
            )
        profile.chat_restricted_until = None

    return profile


@router.post("/conversations/{conversation_id}/messages", response_model=MessageOut)
def send_message(
    conversation_id: str,
    body: SendMessageRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Message:
    conversation = _get_conversation_or_404(db, conversation_id, user.id)
    text = body.text.strip()
    if not text:
        raise HTTPException(status_code=422, detail="Message text is required")

    if conversation.seller_id == SUPPORT_AGENT_ID:
        # Talking to BosDom itself: the peer-to-peer trading policy gate and
        # off-platform-contact flagging don't apply.
        message = Message(conversation_id=conversation.id, sender_id=user.id, text=text)
        db.add(message)
        db.commit()
        db.refresh(message)
        return message

    profile = _require_can_send(db, user)

    flagged = detects_off_platform_attempt(text)
    message = Message(
        conversation_id=conversation.id, sender_id=user.id, text=text, flagged=flagged
    )
    db.add(message)
    if flagged:
        _flag_sender(db, profile)
    db.commit()
    db.refresh(message)

    sender_name, _, _ = _display_for(db, conversation, user.id)
    push_notification(
        category="chat",
        title=f"New message from {sender_name}",
        body=text,
        target=NotificationTarget(route="chatDetail", params={"id": conversation.id}),
    )

    return message


@router.post("/conversations/{conversation_id}/messages/image", response_model=MessageOut)
def send_image_message(
    conversation_id: str,
    file: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Message:
    conversation = _get_conversation_or_404(db, conversation_id, user.id)
    is_support = conversation.seller_id == SUPPORT_AGENT_ID
    if not is_support:
        _require_can_send(db, user)

    filename = save_image_as_webp(file, CHAT_IMAGES_DIR, conversation.id)

    message = Message(
        conversation_id=conversation.id,
        sender_id=user.id,
        image_url=f"/media/chat_images/{filename}",
        flagged=False,
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    if is_support:
        return message

    sender_name, _, _ = _display_for(db, conversation, user.id)
    push_notification(
        category="chat",
        title=f"New message from {sender_name}",
        body="📷 Photo",
        target=NotificationTarget(route="chatDetail", params={"id": conversation.id}),
    )

    return message
