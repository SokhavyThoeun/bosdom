"""One-off: adds the mixed dried fruit & vegetable chips Food & Bev listing
(photos from bosdom/assets/More pic /Food & Bev 1/) to Heng Visal's
"Home 67 sep" shop.

Photos are converted to WebP and uploaded to Supabase Storage like any
listing photo. Safe to re-run: skips if the shop already has the listing.

    uv run python scripts/seed_food_veggie_chips.py --dry-run
    uv run python scripts/seed_food_veggie_chips.py
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
    Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "More pic " / "Food & Bev 1"
)
# Cover first: the bag shot, then the plated close-ups.
PHOTOS = ["IMG_2106.PNG", "IMG_2103.PNG", "IMG_2104.PNG", "IMG_2105.PNG"]

LISTING = dict(
    product_name="Mixed Dried Fruit & Vegetable Chips 1kg Bag",
    category="Food & Bev",
    price=6.5,
    moq_qty=20,
    stock_qty=300,
    description=(
        "Crunchy mix of low-temperature vacuum-fried vegetables and fruit: "
        "okra, pumpkin, sweet potato, purple yam, radish, green beans, "
        "taro, shiitake mushroom, banana and kiwi. Lightly salted, with no "
        "artificial colors, so every piece keeps its natural color.\n\n"
        "A ready-to-eat snack for cafes, mini marts and snack stalls, or "
        "for repacking into smaller retail bags. Sold in resealable 1 kg "
        "bulk bags.\n\n"
        "Specifications:\n"
        "- Net weight: 1 kg per bag\n"
        "- Ingredients: mixed vegetables and fruit, palm oil, sugar, salt\n"
        "- Process: low-temperature vacuum frying\n"
        "- Shelf life: 12 months unopened\n"
        "- Storage: keep sealed in a cool, dry place"
    ),
    sample_testing_enabled=True,
    sample_price=8.0,
    colors=[],
    weight="1kg per bag",
    origin="Vietnam",
    grade="Grade A",
    packaging="1kg resealable bag, 10 bags per carton",
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
