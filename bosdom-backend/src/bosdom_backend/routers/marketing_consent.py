from datetime import datetime, timezone

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/marketing-consent", tags=["marketing-consent"])


class MarketingConsentOut(BaseModel):
    marketing_emails: bool
    consented_at: str | None


class MarketingConsentIn(BaseModel):
    user_id: str
    marketing_emails: bool


_DEFAULT = MarketingConsentOut(marketing_emails=False, consented_at=None)

# In-memory store, mirroring the other routers' lack of a persistence layer.
_consent_by_user: dict[str, MarketingConsentOut] = {}


@router.get("/{user_id}", response_model=MarketingConsentOut)
def get_marketing_consent(user_id: str) -> MarketingConsentOut:
    return _consent_by_user.get(user_id, _DEFAULT)


@router.post("", response_model=MarketingConsentOut)
def save_marketing_consent(payload: MarketingConsentIn) -> MarketingConsentOut:
    consent = MarketingConsentOut(
        marketing_emails=payload.marketing_emails,
        consented_at=datetime.now(timezone.utc).isoformat(),
    )
    _consent_by_user[payload.user_id] = consent
    return consent
