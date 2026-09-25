import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..auth import CurrentUser, get_current_user
from ..db import get_db
from ..models import KycDocument, Profile
from .. import storage
from ..utils.images import encode_webp, save_image_as_webp

router = APIRouter(prefix="/profile", tags=["profile"])


_ALLOWED_KYC_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "application/pdf": ".pdf",
}
# National ID is the one document that puts the seller up for admin KYC
# review — matches the frontend's upload_documents_screen.dart copy. Uploading
# it always moves the profile back to "pending" (even if it was previously
# "verified"/"rejected"), since a changed document invalidates any prior
# admin decision and needs a fresh look.
_VERIFYING_DOC_TYPE = "national_id"
_KYC_DOC_TYPES = {"national_id", "passport", "business_certificate"}


class ProfileOut(BaseModel):
    name: str
    phone: str
    role: str
    email: str
    avatar_url: str = ""
    verification_status: str = "unverified"
    onboarding_complete: bool = False
    # When `verification_status` last changed — e.g. when a seller submitted
    # their national ID (see upload_kyc_document below) or an admin reviewed
    # it (see routers/admin.py). Lets the app show "Submitted on <date>".
    updated_at: datetime

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
    profile = _get_or_create(db, user)
    if profile.verification_status == "rejected" and profile.role == "supplier":
        # Accounts rejected before rejection reverted the role would
        # otherwise stay stuck in the seller view.
        profile.role = "retailer"
        db.commit()
        db.refresh(profile)
    return profile


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


@router.post("/me/complete-onboarding", response_model=ProfileOut)
def complete_onboarding(
    user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db)
) -> Profile:
    """Marks the signup wizard as finished. Called only from the last step
    of each role's flow (delivery address for retailer/buyer, business info
    for supplier) — an account/profile created earlier in the wizard must
    NOT be treated as onboarded until the user actually reaches this point,
    or restoring a session mid-wizard would drop them straight into the app
    instead of resuming signup."""
    profile = _get_or_create(db, user)
    profile.onboarding_complete = True
    db.commit()
    db.refresh(profile)
    return profile


@router.post("/me/avatar", response_model=ProfileOut)
def upload_avatar(
    file: UploadFile = File(...),
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Profile:
    avatar_url = save_image_as_webp(file, "avatars", user.id)

    profile = _get_or_create(db, user)
    profile.avatar_url = avatar_url
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

    data = file.file.read()
    content_type = "application/pdf"
    if ext != ".pdf":
        try:
            data = encode_webp(data)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        ext, content_type = ".webp", "image/webp"
    filename = f"{user.id}-{doc_type}-{uuid.uuid4().hex[:8]}{ext}"
    file_url = storage.upload_private(f"kyc_documents/{filename}", data, content_type)

    profile = _get_or_create(db, user)

    existing = (
        db.query(KycDocument)
        .filter(KycDocument.profile_id == user.id, KycDocument.doc_type == doc_type)
        .one_or_none()
    )
    if existing is not None:
        existing.file_url = file_url
    else:
        db.add(
            KycDocument(
                profile_id=user.id,
                doc_type=doc_type,
                file_url=file_url,
            )
        )

    if doc_type == _VERIFYING_DOC_TYPE:
        profile.verification_status = "pending"

    db.commit()
    db.refresh(profile)
    return profile
