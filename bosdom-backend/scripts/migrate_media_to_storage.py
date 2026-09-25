"""One-off: moves files from the local media/ folder into Supabase Storage
and rewrites every `/media/...` path in the DB to its new location.

Images are converted to WebP (see utils/images.py); PDFs and videos are
uploaded as-is. Safe to re-run: values that were already moved are skipped
and uploads overwrite.

    uv run python scripts/migrate_media_to_storage.py --dry-run
    uv run python scripts/migrate_media_to_storage.py
"""

import mimetypes
import sys
from pathlib import Path

from bosdom_backend import storage
from bosdom_backend.db import SessionLocal
from bosdom_backend.models import (
    CoBuyPool,
    DisputeEvidence,
    KycDocument,
    Listing,
    Message,
    Order,
    OrderReview,
    Profile,
    SellerReport,
    Shop,
)
from bosdom_backend.utils.images import encode_webp

MEDIA_DIR = Path(__file__).resolve().parent.parent / "src" / "bosdom_backend" / "media"
PRIVATE_FOLDERS = {"kyc_documents", "dispute_evidence"}
IMAGE_SUFFIXES = {".jpg", ".jpeg", ".png", ".webp", ".heic", ".heif"}

# (model, column, is_list)
COLUMNS = [
    (Profile, "avatar_url", False),
    (KycDocument, "file_url", False),
    (Shop, "logo_url", False),
    (Shop, "photo_urls", True),
    (Listing, "photo_urls", True),
    (CoBuyPool, "photo_urls", True),
    (Order, "shipping_photo_url", False),
    (Order, "delivery_proof_url", False),
    (SellerReport, "photo_urls", True),
    (DisputeEvidence, "file_url", False),
    (Message, "image_url", False),
    (OrderReview, "photo_urls", True),
]

dry_run = "--dry-run" in sys.argv
moved: dict[str, str] = {}
missing: list[str] = []


def migrate(value: str | None) -> str | None:
    if not value or not value.startswith("/media/") or value.startswith(storage.PRIVATE_URL_PREFIX):
        return value
    if value in moved:
        return moved[value]

    rel = value.removeprefix("/media/")
    folder = rel.split("/", 1)[0]
    source = MEDIA_DIR / rel
    if not source.is_file():
        missing.append(value)
        return value

    data = source.read_bytes()
    dest = rel
    content_type = mimetypes.guess_type(source.name)[0] or "application/octet-stream"
    if source.suffix.lower() in IMAGE_SUFFIXES:
        data = encode_webp(data)
        dest = str(Path(rel).with_suffix(".webp"))
        content_type = "image/webp"

    if dry_run:
        new = f"(would upload {len(data) // 1024} KB) {dest}"
    elif folder in PRIVATE_FOLDERS:
        new = storage.upload_private(dest, data, content_type)
    else:
        new = storage.upload_public(dest, data, content_type)
    print(f"{value}\n  -> {new}")
    moved[value] = new
    return new


def main() -> None:
    if not dry_run:
        storage.ensure_buckets()

    db = SessionLocal()
    try:
        for model, column, is_list in COLUMNS:
            for row in db.query(model).all():
                old = getattr(row, column)
                new = [migrate(v) for v in old or []] if is_list else migrate(old)
                if new != old and not dry_run:
                    setattr(row, column, new)
        if not dry_run:
            db.commit()
    finally:
        db.close()

    print(f"\n{'Would move' if dry_run else 'Moved'} {len(moved)} files.")
    if missing:
        print(f"{len(missing)} DB paths had no local file (left unchanged):")
        for value in missing:
            print(f"  {value}")


if __name__ == "__main__":
    main()
