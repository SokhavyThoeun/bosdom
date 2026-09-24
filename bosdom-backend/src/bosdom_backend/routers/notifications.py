from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import UserNotification

router = APIRouter(prefix="/notifications", tags=["notifications"])

# Newest N only — the feed screen has no pagination.
_FEED_LIMIT = 100


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
    db: Session,
    user_id: str,
    category: str,
    title: str,
    body: str,
    target: NotificationTarget | None = None,
) -> None:
    """Adds an alert to one account's feed and commits. Called by the other
    routers whenever something buyer/seller-relevant happens. Never raises:
    a failed alert must not fail the action that triggered it."""
    try:
        db.add(
            UserNotification(
                user_id=user_id,
                category=category,
                title=title,
                body=body,
                target_route=target.route if target else None,
                target_params=target.params if target else {},
            )
        )
        db.commit()
    except Exception:
        db.rollback()


def _out(row: UserNotification) -> Notification:
    return Notification(
        id=row.id,
        category=row.category,
        title=row.title,
        body=row.body,
        created_at=row.created_at,
        read=row.read,
        target=(
            NotificationTarget(route=row.target_route, params=row.target_params or {})
            if row.target_route
            else None
        ),
    )


def _unread_count(db: Session, user_id: str) -> int:
    return (
        db.query(UserNotification)
        .filter(UserNotification.user_id == user_id, UserNotification.read.is_(False))
        .count()
    )


@router.get("", response_model=NotificationsOut)
def list_notifications(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> NotificationsOut:
    rows = (
        db.query(UserNotification)
        .filter(UserNotification.user_id == user.id)
        .order_by(UserNotification.created_at.desc())
        .limit(_FEED_LIMIT)
        .all()
    )
    return NotificationsOut(
        items=[_out(r) for r in rows], unread_count=_unread_count(db, user.id)
    )


@router.post("/{notification_id}/read", response_model=MarkReadOut)
def mark_read(
    notification_id: str,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MarkReadOut:
    row = db.get(UserNotification, notification_id)
    if row is None or row.user_id != user.id:
        raise HTTPException(status_code=404, detail="Notification not found")
    row.read = True
    db.commit()
    return MarkReadOut(unread_count=_unread_count(db, user.id))


@router.post("/read-all", response_model=MarkReadOut)
def mark_all_read(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> MarkReadOut:
    db.query(UserNotification).filter(
        UserNotification.user_id == user.id, UserNotification.read.is_(False)
    ).update({"read": True})
    db.commit()
    return MarkReadOut(unread_count=0)
