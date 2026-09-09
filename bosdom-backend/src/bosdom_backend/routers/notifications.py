from datetime import datetime, timedelta, timezone
from itertools import count

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/notifications", tags=["notifications"])

_id_counter = count(1)


class NotificationTarget(BaseModel):
    route: str
    params: dict[str, str] = {}


class Notification(BaseModel):
    id: str
    category: str  # chat | order | co_buy | escrow | payment | system
    title: str
    body: str
    created_at: datetime
    read: bool = False
    target: NotificationTarget | None = None


class NotificationsOut(BaseModel):
    items: list[Notification]
    unread_count: int


class MarkReadOut(BaseModel):
    unread_count: int


def push_notification(
    category: str,
    title: str,
    body: str,
    target: NotificationTarget | None = None,
) -> Notification:
    """Append a new alert to the shared feed. Called by other routers
    (chat, co-buy, ...) whenever something buyer/seller-relevant happens."""
    notification = Notification(
        id=f"note-{next(_id_counter)}",
        category=category,
        title=title,
        body=body,
        created_at=datetime.now(timezone.utc),
        target=target,
    )
    _notifications.insert(0, notification)
    return notification


def _seed() -> list[Notification]:
    now = datetime.now(timezone.utc)
    seed_id = count(1)

    def make(
        minutes_ago: int,
        category: str,
        title: str,
        body: str,
        target: NotificationTarget | None = None,
        read: bool = False,
    ) -> Notification:
        return Notification(
            id=f"note-{next(seed_id)}",
            category=category,
            title=title,
            body=body,
            created_at=now - timedelta(minutes=minutes_ago),
            read=read,
            target=target,
        )

    return [
        make(
            4,
            "chat",
            "New message from Mekong Agri-Food Co.",
            "Yes, we have Jasmine Rice available in 25kg and 50kg bags.",
            NotificationTarget(
                route="chatDetail", params={"id": "mekong-agri-food-co"}
            ),
        ),
        make(
            35,
            "co_buy",
            "Co-buy target reached",
            "Fish Sauce 12-pack hit its group buy target. Checkout closes soon.",
            NotificationTarget(
                route="coBuyDetail", params={"id": "fish-sauce-12pack"}
            ),
        ),
        make(
            90,
            "order",
            "Your order has shipped",
            "Order for wholesale cotton shirts is on its way to your address.",
            NotificationTarget(route="orders"),
        ),
        make(
            180,
            "escrow",
            "Funds released from escrow",
            "Payment for your Golden Silk Trading order has been released to the seller.",
            NotificationTarget(route="escrow"),
        ),
        make(
            240,
            "payment",
            "Payment received",
            "Golden Silk Trading confirmed receipt of your invoice payment.",
            read=True,
        ),
        make(
            1440,
            "co_buy",
            "New retailer joined your co-buy",
            "A retailer joined your Palm Sugar 10kg group buy: 25/25 reached.",
            NotificationTarget(route="coBuyDetail", params={"id": "palm-sugar-10kg"}),
            read=True,
        ),
    ]


_notifications: list[Notification] = _seed()


@router.get("", response_model=NotificationsOut)
def list_notifications() -> NotificationsOut:
    items = sorted(_notifications, key=lambda n: n.created_at, reverse=True)
    unread = sum(1 for n in items if not n.read)
    return NotificationsOut(items=items, unread_count=unread)


@router.post("/{notification_id}/read", response_model=MarkReadOut)
def mark_read(notification_id: str) -> MarkReadOut:
    for notification in _notifications:
        if notification.id == notification_id:
            notification.read = True
            return MarkReadOut(unread_count=sum(1 for n in _notifications if not n.read))
    raise HTTPException(status_code=404, detail="Notification not found")


@router.post("/read-all", response_model=MarkReadOut)
def mark_all_read() -> MarkReadOut:
    for notification in _notifications:
        notification.read = True
    return MarkReadOut(unread_count=0)
