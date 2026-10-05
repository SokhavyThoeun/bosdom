"""One-off: adds the cartoon projection light Electronics listing (photos from
bosdom/assets/More pic /eletronic 1/) to Heng Visal's "Home 67 sep" shop.

Photos are converted to WebP and uploaded to Supabase Storage like any
listing photo. Safe to re-run: skips if the shop already has the listing.

    uv run python scripts/seed_electronics_projection_light.py --dry-run
    uv run python scripts/seed_electronics_projection_light.py
"""

import sys
import uuid
from pathlib import Path

from bosdom_backend import storage
from bosdom_backend.db import SessionLocal
from bosdom_backend.models import Listing, Shop
from bosdom_backend.utils.images import encode_webp

SHOP_NAME = "Home 67 sep"
PHOTO_DIR = (
    Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "More pic " / "eletronic 1"
)
# Cover first: the light projecting on the road, then bike demo, pattern
# cartridges and battery shots.
PHOTOS = ["IMG_2127.PNG", "IMG_2130.PNG", "IMG_2128.PNG", "IMG_2129.PNG"]

LISTING = dict(
    product_name="Cartoon LED Ground Projection Light for Bikes & Motorbikes",
    category="Electronics",
    price=1.9,
    moq_qty=50,
    stock_qty=1200,
    description=(
        "A small clip-on LED light that projects a bright, animated cartoon "
        "character onto the ground beside your bicycle, e-bike, motorbike "
        "or car. Fun to look at, and it makes riders easier to spot at "
        "night, warning others that you are there.\n\n"
        "Patterns come on swappable cartridges, so you can change the "
        "character anytime in a few seconds. Runs on AAA batteries: just "
        "press and pull the case open to insert or replace them. No wiring "
        "needed, it straps or sticks onto the frame, fender or bumper.\n\n"
        "Specifications:\n"
        "- Light source: LED with blue indicator\n"
        "- Power: 2 x AAA batteries (not included)\n"
        "- Patterns: interchangeable cartoon cartridges\n"
        "- Fits: bicycles, electric scooters, motorbikes, cars\n"
        "- Finish: glossy black ABS case\n"
        "- Sold as: single pack"
    ),
    sample_testing_enabled=True,
    sample_price=3.0,
    colors=[{"name": "Glossy Black", "hex": "#111111"}],
    weight="80g",
    origin="China",
    grade="Grade A",
    packaging="Retail box per unit, 100 units per carton",
)

dry_run = "--dry-run" in sys.argv


def main() -> None:
    db = SessionLocal()
    try:
        shops = db.query(Shop).filter(Shop.shop_name.ilike(SHOP_NAME)).all()
        if len(shops) != 1:
            names = [s.shop_name for s in db.query(Shop).all()]
            sys.exit(f"Expected 1 shop named {SHOP_NAME!r}, found {len(shops)}. Shops: {names}")
        shop = shops[0]

        exists = (
            db.query(Listing)
            .filter(
                Listing.seller_id == shop.id,
                Listing.product_name == LISTING["product_name"],
            )
            .first()
        )
        if exists:
            print(f"Already listed ({exists.id}), nothing to do.")
            return

        photo_urls = []
        for name in PHOTOS:
            webp = encode_webp((PHOTO_DIR / name).read_bytes())
            path = f"listing_photos/{shop.id}-{uuid.uuid4().hex[:8]}.webp"
            if dry_run:
                print(f"(would upload {len(webp) // 1024} KB) {path}")
                photo_urls.append(path)
            else:
                photo_urls.append(storage.upload_public(path, webp, "image/webp"))

        print(f"Shop: {shop.shop_name} ({shop.id})")
        if dry_run:
            print(f"Would add: {LISTING['product_name']}")
            return

        listing = Listing(seller_id=shop.id, photo_urls=photo_urls, **LISTING)
        db.add(listing)
        db.commit()
        print(f"Added listing {listing.id}: {listing.product_name}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
