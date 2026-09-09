import jwt
from fastapi import Header, HTTPException

from .config import settings

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


def get_current_user(authorization: str = Header(...)) -> CurrentUser:
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

    # Populated from our own email signup's `data` payload, or (for Google)
    # by Supabase itself from the provider's profile info.
    user_metadata = payload.get("user_metadata") or {}
    return CurrentUser(
        id=payload["sub"],
        email=payload.get("email"),
        name=user_metadata.get("name") or user_metadata.get("full_name"),
        avatar_url=user_metadata.get("avatar_url") or user_metadata.get("picture"),
    )
