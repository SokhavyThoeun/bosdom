from datetime import datetime, timedelta, timezone

import jwt
from fastapi import Header, HTTPException

from .config import settings

_ALGORITHM = "HS256"
_TOKEN_TTL = timedelta(hours=12)


def create_admin_token() -> str:
    payload = {
        "role": "admin",
        "exp": datetime.now(timezone.utc) + _TOKEN_TTL,
    }
    return jwt.encode(payload, settings.admin_jwt_secret, algorithm=_ALGORITHM)


def get_current_admin(authorization: str = Header(...)) -> None:
    """Guards every `/admin/*` route except `/admin/auth/login`. Deliberately
    separate from `get_current_user` (auth.py) — there's a single hardcoded
    operator account (`settings.admin_email`/`admin_password`) rather than a
    role on the regular Supabase-backed `Profile` table."""
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")

    token = authorization.removeprefix("Bearer ")
    try:
        payload = jwt.decode(token, settings.admin_jwt_secret, algorithms=[_ALGORITHM])
    except jwt.PyJWTError as exc:
        raise HTTPException(
            status_code=401, detail="Invalid or expired admin token"
        ) from exc

    if payload.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Not an admin token")
