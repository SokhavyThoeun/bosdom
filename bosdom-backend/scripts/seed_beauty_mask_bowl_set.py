"""One-off: adds the DIY face mask bowl set Beauty listing (photos from
bosdom/assets/More pic /Beauty 1/) to Heng Visal's "Home 67 sep" shop.

Photos are converted to WebP and uploaded to Supabase Storage like any
listing photo. Safe to re-run: skips if the shop already has the listing.

    uv run python scripts/seed_beauty_mask_bowl_set.py --dry-run
    uv run python scripts/seed_beauty_mask_bowl_set.py
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
    Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "More pic " / "Beauty 1"
)
# Cover first: the full set in all colors, then the detail shots.
PHOTOS = ["IMG_2109.PNG", "IMG_2110.PNG", "IMG_2112.PNG", "IMG_2111.PNG", "IMG_2113.PNG"]

LISTING = dict(
    product_name="DIY Face Mask Bowl Set (5 pcs)",
    category="Beauty",
    price=0.9,
    moq_qty=50,
    stock_qty=2000,
    description=(
        "Everything needed to mix and apply clay, powder or fresh face "
        "masks at home or in a salon: a mixing bowl, a mixing stick, a "
        "measuring spoon, a silicone mask brush and a soft-bristle brush.\n\n"
        "The smooth, rounded mixing stick stirs masks to an even paste, "
        "and the spatula-shaped silicone brush spreads it in a thin, even "
        "layer without soaking up product. Medium-size bowl fits one to "
        "two treatments. Rinses clean with water.\n\n"
        "Specifications:\n"
        "- Set includes: 1 bowl, 1 mixing stick, 1 measuring spoon, "
        "1 silicone brush, 1 soft brush\n"
        "- Bowl size: approx. 10 x 6 cm (diameter x height)\n"
        "- Material: PP plastic bowl and tools, silicone brush head, "
        "nylon bristles\n"
        "- Reusable and easy to clean"
    ),
    sample_testing_enabled=True,
    sample_price=1.5,
    colors=[
        {"name": "Pink", "hex": "#F4A7B9"},
        {"name": "Green", "hex": "#A8E6A1"},
        {"name": "White", "hex": "#F5F5F5"},
    ],
    weight="0.08 kg per set",
    origin="China",
    grade="PP plastic + silicone",
    packaging="OPP bag per set, 200 sets per carton",
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
