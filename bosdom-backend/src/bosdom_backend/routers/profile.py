import uuid
from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile
from pydantic import BaseModel

router = APIRouter(prefix="/profile", tags=["profile"])

AVATAR_DIR = Path(__file__).resolve().parent.parent / "media" / "avatars"
_ALLOWED_AVATAR_TYPES = {"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}


class ProfileOut(BaseModel):
    name: str
    phone: str
    role: str
    email: str
    avatar_url: str = ""


class ProfileIn(BaseModel):
    user_id: str
    name: str
    phone: str
    role: str
    email: str


_DEFAULT = ProfileOut(
    name="Sokhavy Thoeun",
    phone="+855 76 227 5858",
    role="retailer",
    email="",
)

# In-memory store, mirroring the other routers' lack of a persistence layer.
_profile_by_user: dict[str, ProfileOut] = {}


@router.get("/{user_id}", response_model=ProfileOut)
def get_profile(user_id: str) -> ProfileOut:
    return _profile_by_user.get(user_id, _DEFAULT)


@router.post("", response_model=ProfileOut)
def save_profile(payload: ProfileIn) -> ProfileOut:
    existing = _profile_by_user.get(user_id := payload.user_id)
    profile = ProfileOut(
        name=payload.name.strip(),
        phone=payload.phone.strip(),
        role=payload.role.strip(),
        email=payload.email.strip(),
        avatar_url=existing.avatar_url if existing else "",
    )
    _profile_by_user[user_id] = profile
    return profile


@router.post("/{user_id}/avatar", response_model=ProfileOut)
def upload_avatar(user_id: str, file: UploadFile = File(...)) -> ProfileOut:
    ext = _ALLOWED_AVATAR_TYPES.get(file.content_type or "")
    if ext is None:
        raise HTTPException(status_code=400, detail="Unsupported image type")

    AVATAR_DIR.mkdir(parents=True, exist_ok=True)
    filename = f"{user_id}-{uuid.uuid4().hex[:8]}{ext}"
    with (AVATAR_DIR / filename).open("wb") as out:
        out.write(file.file.read())

    profile = _profile_by_user.get(user_id, _DEFAULT).model_copy(
        update={"avatar_url": f"/media/avatars/{filename}"}
    )
    _profile_by_user[user_id] = profile
    return profile
