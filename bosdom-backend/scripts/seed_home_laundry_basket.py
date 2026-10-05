"""One-off: adds the laundry basket Home listing (photos from
bosdom/assets/More pic /Home product 2/) to Heng Visal's "Home 67 sep" shop.

Photos are converted to WebP and uploaded to Supabase Storage like any
listing photo. Safe to re-run: skips if the shop already has the listing.

    uv run python scripts/seed_home_laundry_basket.py --dry-run
    uv run python scripts/seed_home_laundry_basket.py
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
    Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "More pic " / "Home product 2"
)
# Cover first: the plain product shot, then the room shots.
PHOTOS = ["IMG_2102.PNG", "IMG_2099.PNG", "IMG_2100.PNG", "IMG_2101.PNG"]

LISTING = dict(
    product_name="Foldable Grid Laundry Basket (Cotton Linen)",
    category="Home",
    price=1.8,
    moq_qty=20,
    stock_qty=500,
    description=(
        "Round laundry hamper in cotton-linen fabric with a simple grid "
        "print, in black, gray or white. Two soft carry handles make it "
        "easy to move a full load from the bedroom to the washing machine.\n\n"
        "A waterproof coating on the inside keeps damp clothes from soaking "
        "through, and the steel wire rim holds the basket upright when "
        "empty. Folds flat for storage and shipping. Also works as a toy, "
        "blanket or dirty-towel bin.\n\n"
        "Specifications:\n"
        "- Size: approx. 35 x 45 cm (diameter x height)\n"
        "- Capacity: about 43 L\n"
        "- Material: cotton-linen fabric, waterproof PE inner coating\n"
        "- Frame: steel wire rim\n"
        "- Handles: 2 cotton webbing handles\n"
        "- Folds flat to about 3 cm"
    ),
    sample_testing_enabled=True,
    sample_price=3.5,
    colors=[
        {"name": "Black", "hex": "#1A1A1A"},
        {"name": "Gray", "hex": "#9E9E9E"},
        {"name": "White", "hex": "#F5F5F5"},
    ],
    weight="0.3 kg per piece",
    origin="China",
    grade="Cotton linen + PE coating",
    packaging="Folded flat, 50 pcs per carton",
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
