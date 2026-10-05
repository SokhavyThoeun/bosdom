"""One-off: adds the shoe rack Home listing (photos from
bosdom/assets/More pic /Home product 1/) to Heng Visal's "Home 67 sep" shop.

Photos are converted to WebP and uploaded to Supabase Storage like any
listing photo. Safe to re-run: skips if the shop already has the listing.

    uv run python scripts/seed_home_shoe_rack.py --dry-run
    uv run python scripts/seed_home_shoe_rack.py
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
    Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "More pic " / "Home product 1"
)
# Cover first: the plain product shot, then the feature shots.
PHOTOS = ["IMG_2095.PNG", "IMG_2096.PNG", "IMG_2097.PNG", "IMG_2098.PNG"]

LISTING = dict(
    product_name="5-Tier Metal Shoe Rack (Adjustable, Black)",
    category="Home",
    price=6.5,
    moq_qty=10,
    stock_qty=300,
    description=(
        "Freestanding 5-tier shoe rack in matte black steel with curved "
        "carry handles on top. One rack holds flats, leather shoes, "
        "sneakers and high-tops, with the top shelf free for bags and "
        "small items.\n\n"
        "Adjustable shelf distance: the shelf rods can be removed so two "
        "tiers become one tall layer, turning it into a boot rack that "
        "fits tall boots and high heels. A narrow 3-tier setup also fits "
        "small dormitory and entryway spaces.\n\n"
        "Specifications:\n"
        "- Tiers: 5 (shelves adjustable)\n"
        "- Size: approx. 62 x 26 x 80 cm (W x D x H)\n"
        "- Capacity: about 15-20 pairs of shoes\n"
        "- Load: up to 5 kg per tier\n"
        "- Frame: steel tubes, black coating; plastic joints and anti-slip "
        "feet\n"
        "- Assembly: tool-free, push-fit connectors"
    ),
    sample_testing_enabled=True,
    sample_price=9.0,
    weight="2.6 kg per set",
    origin="China",
    grade="Carbon steel + PP plastic",
    packaging="Flat-pack carton, 10 sets per master carton",
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
