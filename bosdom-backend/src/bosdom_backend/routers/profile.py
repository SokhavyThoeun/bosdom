import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import KycDocument, Profile

router = APIRouter(prefix="/profile", tags=["profile"])

AVATAR_DIR = Path(__file__).resolve().parent.parent / "media" / "avatars"
_ALLOWED_AVATAR_TYPES = {"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}

KYC_DIR = Path(__file__).resolve().parent.parent / "media" / "kyc_documents"
_ALLOWED_KYC_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "application/pdf": ".pdf",
}
# National ID is the one document that immediately activates the seller badge
# (no admin review) — matches the frontend's upload_documents_screen.dart copy.
_VERIFYING_DOC_TYPE = "national_id"
_KYC_DOC_TYPES = {"national_id", "passport", "business_certificate"}


class ProfileOut(BaseModel):
    name: str
    phone: str
    role: str
    email: str
    avatar_url: str = ""
    verification_status: str = "unverified"

    model_config = {"from_attributes": True}


class KycDocumentOut(BaseModel):
    doc_type: str
    file_url: str

    model_config = {"from_attributes": True}


class ProfileIn(BaseModel):
    name: str
    phone: str
    role: str
    email: str


def _get_or_create(db: Session, user: CurrentUser) -> Profile:
    profile = db.get(Profile, user.id)
    if profile is None:
        profile = Profile(
            id=user.id,
            email=user.email or "",
            name=user.name or "",
            avatar_url=user.avatar_url or "",
        )
        db.add(profile)
        db.commit()
        db.refresh(profile)
    elif not profile.name and user.name:
        # Backfills profiles created before the account's name was known,
        # e.g. from a first sign-in that predates this field being read.
        profile.name = user.name
        db.commit()
        db.refresh(profile)
    return profile


@router.get("/me", response_model=ProfileOut)
def get_profile(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> Profile:
    return _get_or_create(db, user)


@router.post("/me", response_model=ProfileOut)
def save_profile(
    payload: ProfileIn,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Profile:
    profile = _get_or_create(db, user)
    profile.name = payload.name.strip()
    profile.phone = payload.phone.strip()
    profile.role = payload.role.strip()
    profile.email = payload.email.strip()
    db.commit()
    db.refresh(profile)
    return profile


@router.post("/me/avatar", response_model=ProfileOut)
def upload_avatar(
    file: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Profile:
    ext = _ALLOWED_AVATAR_TYPES.get(file.content_type or "")
    if ext is None:
        raise HTTPException(status_code=400, detail="Unsupported image type")

    AVATAR_DIR.mkdir(parents=True, exist_ok=True)
    filename = f"{user.id}-{uuid.uuid4().hex[:8]}{ext}"
    with (AVATAR_DIR / filename).open("wb") as out:
        out.write(file.file.read())

    profile = _get_or_create(db, user)
    profile.avatar_url = f"/media/avatars/{filename}"
    db.commit()
    db.refresh(profile)
    return profile


@router.get("/me/kyc-documents", response_model=list[KycDocumentOut])
def list_kyc_documents(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> list[KycDocument]:
    return (
        db.query(KycDocument)
        .filter(KycDocument.profile_id == user.id)
        .order_by(KycDocument.uploaded_at)
        .all()
    )


@router.post("/me/kyc-documents", response_model=ProfileOut)
def upload_kyc_document(
    doc_type: str = Form(...),
    file: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Profile:
    if doc_type not in _KYC_DOC_TYPES:
        raise HTTPException(status_code=400, detail="Unknown document type")

    ext = _ALLOWED_KYC_TYPES.get(file.content_type or "")
    if ext is None:
        raise HTTPException(status_code=400, detail="Unsupported file type")

    KYC_DIR.mkdir(parents=True, exist_ok=True)
    filename = f"{user.id}-{doc_type}-{uuid.uuid4().hex[:8]}{ext}"
    with (KYC_DIR / filename).open("wb") as out:
        out.write(file.file.read())

    profile = _get_or_create(db, user)

    existing = (
        db.query(KycDocument)
        .filter(KycDocument.profile_id == user.id, KycDocument.doc_type == doc_type)
        .one_or_none()
    )
    if existing is not None:
        existing.file_url = f"/media/kyc_documents/{filename}"
    else:
        db.add(
            KycDocument(
                profile_id=user.id,
                doc_type=doc_type,
                file_url=f"/media/kyc_documents/{filename}",
            )
        )

    if doc_type == _VERIFYING_DOC_TYPE:
        profile.verification_status = "verified"

    db.commit()
    db.refresh(profile)
    return profile
