from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/ads-consent", tags=["ads-consent"])


class AdsConsentOut(BaseModel):
    ads_enabled: bool
    browsing_data: bool
    purchase_history: bool


class AdsConsentIn(BaseModel):
    user_id: str
    ads_enabled: bool
    browsing_data: bool
    purchase_history: bool


_DEFAULT = AdsConsentOut(ads_enabled=False, browsing_data=True, purchase_history=True)

# In-memory store, mirroring the other routers' lack of a persistence layer.
_consent_by_user: dict[str, AdsConsentOut] = {}


@router.get("/{user_id}", response_model=AdsConsentOut)
def get_ads_consent(user_id: str) -> AdsConsentOut:
    return _consent_by_user.get(user_id, _DEFAULT)


@router.post("", response_model=AdsConsentOut)
def save_ads_consent(payload: AdsConsentIn) -> AdsConsentOut:
    consent = AdsConsentOut(
        ads_enabled=payload.ads_enabled,
        browsing_data=payload.browsing_data,
        purchase_history=payload.purchase_history,
    )
    _consent_by_user[payload.user_id] = consent
    return consent
