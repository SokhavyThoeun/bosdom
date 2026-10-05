"""One-off: tops up the seeded listings that only got 2 photos with the rest
of their product folder in bosdom/assets/pic for bosdom product/.

A folder photo is skipped when it already matches one of the listing's
photos (compared as small grayscale thumbnails), so only the missing ones
are uploaded and appended. Safe to re-run.

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
from bosdom_backend.models import Listing
from bosdom_backend.utils.images import encode_webp

PHOTO_ROOT = Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "pic for bosdom product"

# Listing name -> the folder its seeded photos came from.
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

# Mean per-pixel difference (0-255) below which two thumbnails are the
# same photo; WebP re-encoding stays well under this.
SAME_PHOTO = 12

dry_run = "--dry-run" in sys.argv


def _thumb(data: bytes) -> list[int]:
    im = Image.open(io.BytesIO(data)).convert("L").resize((16, 16))
    return list(im.tobytes())


def _diff(a: list[int], b: list[int]) -> float:
    return sum(abs(x - y) for x, y in zip(a, b)) / len(a)


def main() -> None:
    db = SessionLocal()
    try:
        for name, folder in FOLDERS.items():
            listing = db.query(Listing).filter(Listing.product_name == name).first()
            if listing is None:
                print(f"!! {name}: listing not found, skipped")
                continue

            existing = [
                _thumb(urllib.request.urlopen(url).read()) for url in listing.photo_urls
            ]
            files = sorted(
                p for p in (PHOTO_ROOT / folder).iterdir() if p.name != ".DS_Store"
            )
            added = []
            for f in files:
                data = f.read_bytes()
                best = min((_diff(_thumb(data), t) for t in existing), default=255)
                if best < SAME_PHOTO:
                    continue
                webp = encode_webp(data)
                path = f"listing_photos/{listing.seller_id}-{uuid.uuid4().hex[:8]}.webp"
                if dry_run:
                    print(f"   (would upload {len(webp) // 1024} KB, diff {best:.0f}) {f.name}")
                    added.append(path)
                else:
                    added.append(storage.upload_public(path, webp, "image/webp"))

            print(f"{name}: {len(listing.photo_urls)} -> {len(listing.photo_urls) + len(added)}")
            if added and not dry_run:
                listing.photo_urls = [*listing.photo_urls, *added]
                db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    main()
