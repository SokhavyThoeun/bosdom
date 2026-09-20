import jwt
from fastapi import Depends, Header, HTTPException
from sqlalchemy.orm import Session

from .config import settings
from .db import get_db
from .models import Profile

_jwks_client = jwt.PyJWKClient(f"{settings.supabase_url}/auth/v1/.well-known/jwks.json")


class CurrentUser:
    def __init__(
        self,
        id: str,
        email: str | None,
        name: str | None = None,
        avatar_url: str | None = None,
    ):
        self.id = id
        self.email = email
        self.name = name
        self.avatar_url = avatar_url


def require_verified_seller(user: CurrentUser, db: Session) -> None:
    """Blocks a seller action until admin KYC review clears the account.

    Registering as a seller (role="supplier") doesn't grant selling rights
    by itself — the profile stays "unverified"/"pending"/"rejected" until an
    admin approves it (see routers/admin.py). Buying/browsing is unaffected.
    """
    profile = db.get(Profile, user.id)
    if profile is None or profile.verification_status != "verified":
        raise HTTPException(
            status_code=403,
            detail=(
                "Your seller account is pending admin approval. "
                "You can still browse and shop while you wait."
            ),
        )


def get_current_user(
    authorization: str = Header(...), db: Session = Depends(get_db)
) -> CurrentUser:
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")

    token = authorization.removeprefix("Bearer ")
    try:
        signing_key = _jwks_client.get_signing_key_from_jwt(token)
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["ES256", "RS256"],
            audience="authenticated",
        )
    except jwt.PyJWTError as exc:
        raise HTTPException(status_code=401, detail="Invalid or expired token") from exc

    # Blocks a suspended account (set via the admin panel, see routers/admin.py)
    # from calling any endpoint that identifies the caller, without touching
    # the Supabase session itself.
    profile = db.get(Profile, payload["sub"])
    if profile is not None and profile.is_suspended:
        raise HTTPException(status_code=403, detail="This account has been suspended")

    # Populated from our own email signup's `data` payload, or (for Google)
    # by Supabase itself from the provider's profile info.
    user_metadata = payload.get("user_metadata") or {}
    return CurrentUser(
        id=payload["sub"],
        email=payload.get("email"),
        name=user_metadata.get("name") or user_metadata.get("full_name"),
        avatar_url=user_metadata.get("avatar_url") or user_metadata.get("picture"),
    )
