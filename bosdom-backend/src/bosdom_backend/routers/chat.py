import re
from datetime import datetime, timedelta, timezone
from itertools import count

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from .notifications import NotificationTarget, push_notification

router = APIRouter(prefix="/chat", tags=["chat"])

_message_id_counter = count(1)

_AUTO_REPLY = (
    "Thanks for the message! We'll get back to you shortly."
)

_SUPPORT_AUTO_REPLY = (
    "Thanks for reaching out. A BosDom support agent will review your "
    "message and reply here shortly."
)


class Message(BaseModel):
    id: str
    sender: str  # "me" | "them"
    text: str | None = None
    image_caption: str | None = None
    created_at: datetime


class Conversation(BaseModel):
    id: str
    name: str
    kind: str  # maps to an icon/color on the client
    verified: bool
    online: bool
    unread_count: int
    messages: list[Message]


class ConversationSummary(BaseModel):
    id: str
    name: str
    kind: str
    verified: bool
    online: bool
    unread_count: int
    last_message_preview: str
    last_message_at: datetime | None


class SendMessageRequest(BaseModel):
    text: str


class StartConversationRequest(BaseModel):
    name: str
    verified: bool = False


class StartAdminConversationRequest(BaseModel):
    user_id: str


class SendMessageOut(BaseModel):
    messages: list[Message]


class MarkReadOut(BaseModel):
    unread_count: int


def _msg(sender: str, minutes_ago: int, text: str | None = None, image_caption: str | None = None) -> Message:
    return Message(
        id=f"msg-{next(_message_id_counter)}",
        sender=sender,
        text=text,
        image_caption=image_caption,
        created_at=datetime.now(timezone.utc) - timedelta(minutes=minutes_ago),
    )


_ADMIN_WELCOME_MESSAGE = (
    "Hello! Welcome to BosDom Wholesale Support. How can we assist you with "
    "your business orders, disputes, or payments today?"
)


def _seed() -> dict[str, Conversation]:
    conversations = [
        Conversation(
            id="mekong-agri-food-co",
            name="Mekong Agri-Food Co.",
            kind="rice",
            verified=True,
            online=True,
            unread_count=2,
            messages=[
                _msg("them", 30, "Hello! Thank you for your interest in our products. How can I help you today?"),
                _msg("me", 29, "Hi, I would like to inquire about your Jasmine Rice stock."),
                _msg("them", 28, "Yes, we have Jasmine Rice available in 25kg and 50kg bags. For orders above 500kg, we offer a 5% discount."),
                _msg("me", 27, "That sounds great! Can you send me a photo of the latest batch?"),
                _msg("them", 25, image_caption="Jasmine Rice - Grade A Premium"),
            ],
        ),
        Conversation(
            id="phnom-penh-textiles",
            name="Phnom Penh Textiles",
            kind="textile",
            verified=True,
            online=False,
            unread_count=1,
            messages=[
                _msg("them", 100, "Good morning! Thanks for reaching out about our cotton line."),
                _msg("them", 95, "Your order of wholesale cotton shirts has been confirmed and is being packed."),
            ],
        ),
        Conversation(
            id="siem-reap-handicrafts",
            name="Siem Reap Handicrafts",
            kind="handicraft",
            verified=False,
            online=False,
            unread_count=0,
            messages=[
                _msg("them", 1440, "Can you send the product catalog with bulk pricing?"),
            ],
        ),
        Conversation(
            id="battambang-rice-mill",
            name="Battambang Rice Mill",
            kind="grain",
            verified=True,
            online=False,
            unread_count=0,
            messages=[
                _msg("them", 1500, "Our premium fragrant broken rice has a minimum order of 200kg."),
            ],
        ),
        Conversation(
            id="cambodia-fresh-produce",
            name="Cambodia Fresh Produce",
            kind="produce",
            verified=False,
            online=True,
            unread_count=0,
            messages=[
                _msg("them", 4000, "The fresh batch of Kampot durians arrived and is ready for pickup."),
            ],
        ),
        Conversation(
            id="golden-silk-trading",
            name="Golden Silk Trading",
            kind="silk",
            verified=True,
            online=False,
            unread_count=0,
            messages=[
                _msg("them", 8000, "Thank you for the invoice payment. Preparing your shipment now."),
            ],
        ),
    ]
    return {c.id: c for c in conversations}


_conversations: dict[str, Conversation] = _seed()


def _get_or_404(conversation_id: str) -> Conversation:
    conversation = _conversations.get(conversation_id)
    if conversation is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return conversation


def _to_summary(conversation: Conversation) -> ConversationSummary:
    last = conversation.messages[-1] if conversation.messages else None
    if last is None:
        preview = ""
    elif last.text is not None:
        preview = last.text
    else:
        preview = f"📷 {last.image_caption or 'Photo'}"
    return ConversationSummary(
        id=conversation.id,
        name=conversation.name,
        kind=conversation.kind,
        verified=conversation.verified,
        online=conversation.online,
        unread_count=conversation.unread_count,
        last_message_preview=preview,
        last_message_at=last.created_at if last else None,
    )


def _slugify(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


@router.post("/conversations", response_model=ConversationSummary)
def start_conversation(body: StartConversationRequest) -> ConversationSummary:
    conversation_id = _slugify(body.name)
    existing = _conversations.get(conversation_id)
    if existing is not None:
        return _to_summary(existing)

    conversation = Conversation(
        id=conversation_id,
        name=body.name,
        kind="store",
        verified=body.verified,
        online=False,
        unread_count=0,
        messages=[],
    )
    _conversations[conversation_id] = conversation
    return _to_summary(conversation)


def _admin_conversation_id(user_id: str) -> str:
    return f"admin-{user_id}"


@router.post("/admin/conversations", response_model=ConversationSummary)
def start_admin_conversation(body: StartAdminConversationRequest) -> ConversationSummary:
    conversation_id = _admin_conversation_id(body.user_id)
    existing = _conversations.get(conversation_id)
    if existing is not None:
        return _to_summary(existing)

    conversation = Conversation(
        id=conversation_id,
        name="BosDom Support",
        kind="support",
        verified=True,
        online=True,
        unread_count=0,
        messages=[_msg("them", 0, _ADMIN_WELCOME_MESSAGE)],
    )
    _conversations[conversation_id] = conversation
    return _to_summary(conversation)


@router.get("/conversations", response_model=list[ConversationSummary])
def list_conversations(user_id: str | None = None) -> list[ConversationSummary]:
    own_admin_id = _admin_conversation_id(user_id) if user_id else None
    visible = [
        c
        for c in _conversations.values()
        if not c.id.startswith("admin-") or c.id == own_admin_id
    ]
    ordered = sorted(
        visible,
        key=lambda c: c.messages[-1].created_at if c.messages else datetime.min.replace(tzinfo=timezone.utc),
        reverse=True,
    )
    return [_to_summary(c) for c in ordered]


@router.get("/conversations/{conversation_id}", response_model=Conversation)
def get_conversation(conversation_id: str) -> Conversation:
    return _get_or_404(conversation_id)


@router.post("/conversations/{conversation_id}/read", response_model=MarkReadOut)
def mark_read(conversation_id: str) -> MarkReadOut:
    conversation = _get_or_404(conversation_id)
    conversation.unread_count = 0
    return MarkReadOut(unread_count=0)


@router.post(
    "/conversations/{conversation_id}/messages", response_model=SendMessageOut
)
def send_message(conversation_id: str, body: SendMessageRequest) -> SendMessageOut:
    conversation = _get_or_404(conversation_id)
    text = body.text.strip()
    if not text:
        raise HTTPException(status_code=422, detail="Message text is required")

    mine = Message(
        id=f"msg-{next(_message_id_counter)}",
        sender="me",
        text=text,
        created_at=datetime.now(timezone.utc),
    )
    conversation.messages.append(mine)

    reply_text = (
        _SUPPORT_AUTO_REPLY if conversation.kind == "support" else _AUTO_REPLY
    )
    reply = Message(
        id=f"msg-{next(_message_id_counter)}",
        sender="them",
        text=reply_text,
        created_at=datetime.now(timezone.utc),
    )
    conversation.messages.append(reply)

    push_notification(
        category="chat",
        title=f"New message from {conversation.name}",
        body=reply_text,
        target=(
            NotificationTarget(route="liveChat", params={})
            if conversation.kind == "support"
            else NotificationTarget(route="chatDetail", params={"id": conversation.id})
        ),
    )

    return SendMessageOut(messages=[mine, reply])
