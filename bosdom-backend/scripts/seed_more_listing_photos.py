"""One-off: tops up the seeded listings and co-buy deals that only got 2
photos with the rest of their product folder in
bosdom/assets/pic for bosdom product/.

A folder photo is skipped when it already matches one of the listing's
photos (compared as small grayscale thumbnails), so only the missing ones
are uploaded and appended (up to each table's photo limit). Safe to re-run.

    uv run python scripts/seed_more_listing_photos.py --dry-run
    uv run python scripts/seed_more_listing_photos.py
"""

import io
import sys
import urllib.request
import uuid
from pathlib import Path

from PIL import Image

from bosdom_backend import storage
from bosdom_backend.db import SessionLocal
from bosdom_backend.models import CoBuyPool, Listing
from bosdom_backend.utils.images import encode_webp

PHOTO_ROOT = Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "pic for bosdom product"

# Product name -> the folder its seeded photos came from. Co-buy deals reuse
# their listing's name.
FOLDERS = {
    "Coconut Body Lotion 250ml": "beauty ",
    "Aloe Vera Face Gel 100ml": "beauty ",
    "Cotton Polo Shirt Bulk Pack": "Clothes/T shirt",
    "T Shirt": "Clothes/T shirt",
    "Denim Jacket Wholesale": "Clothes/tote bag",
    "Portable Power Bank 20000mAh": "Eletronic/charger type c",
    "LED Desk Lamp with USB Charging": "Eletronic/charger type c",
    "Wireless Earbuds Pro": "Eletronic/earbud",
    "Roasted Cashew Nuts 5kg Pack": "Food bev/Snack",
    "Premium Jasmine Rice 25kg Bag": "Food bev/Rice bulk",
    "Stainless Steel Cookware Set": "Home/stainless bottle",
    "Ceramic Dinnerware Set": "Home/paper cup",
    "Bamboo Kitchen Utensil Set": "Home/kitchen towel",
}

# Co-buy deals seeded from a different folder than their listing.
CO_BUY_FOLDERS = {**FOLDERS, "Portable Power Bank 20000mAh": "Eletronic/earbud"}

# Mean per-pixel difference (0-255) below which two thumbnails are the
# same photo; WebP re-encoding stays well under this.
SAME_PHOTO = 12

# Table, folders, storage folder, photo limit (routers/listings.py,
# routers/co_buy.py).
TARGETS = [
    (Listing, FOLDERS, "listing_photos", 5),
    (CoBuyPool, CO_BUY_FOLDERS, "co_buy_photos", 4),
]

dry_run = "--dry-run" in sys.argv


def _thumb(data: bytes) -> list[int]:
    im = Image.open(io.BytesIO(data)).convert("L").resize((16, 16))
    return list(im.tobytes())


def _diff(a: list[int], b: list[int]) -> float:
    return sum(abs(x - y) for x, y in zip(a, b)) / len(a)


def top_up(db, row, folder: str, storage_dir: str, limit: int) -> None:
    existing = [_thumb(urllib.request.urlopen(url).read()) for url in row.photo_urls]
    files = sorted(p for p in (PHOTO_ROOT / folder).iterdir() if p.name != ".DS_Store")
    added = []
    for f in files:
        if len(row.photo_urls) + len(added) >= limit:
            break
        data = f.read_bytes()
        best = min((_diff(_thumb(data), t) for t in existing), default=255)
        if best < SAME_PHOTO:
            continue
        webp = encode_webp(data)
        path = f"{storage_dir}/{row.seller_id}-{uuid.uuid4().hex[:8]}.webp"
        if dry_run:
            print(f"   (would upload {len(webp) // 1024} KB, diff {best:.0f}) {f.name}")
            added.append(path)
        else:
            added.append(storage.upload_public(path, webp, "image/webp"))

    print(f"{row.product_name}: {len(row.photo_urls)} -> {len(row.photo_urls) + len(added)}")
    if added and not dry_run:
        row.photo_urls = [*row.photo_urls, *added]
        db.commit()


def main() -> None:
    db = SessionLocal()
    try:
        for model, folders, storage_dir, limit in TARGETS:
            print(f"== {model.__tablename__}")
            for name, folder in folders.items():
                for row in db.query(model).filter(model.product_name == name).all():
                    top_up(db, row, folder, storage_dir, limit)
    finally:
        db.close()


if __name__ == "__main__":
    main()
