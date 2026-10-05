"""One-off: adds the stainless steel gua sha set Beauty listing (photos from
bosdom/assets/More pic /Beauty 2/) to Heng Visal's "Home 67 sep" shop.

Photos are converted to WebP and uploaded to Supabase Storage like any
listing photo. Safe to re-run: skips if the shop already has the listing.

    uv run python scripts/seed_beauty_gua_sha.py --dry-run
    uv run python scripts/seed_beauty_gua_sha.py
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
    Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "More pic " / "Beauty 2"
)
# Cover first: both boards without text, then the labeled and detail shots.
PHOTOS = ["IMG_2117.PNG", "IMG_2114.PNG", "IMG_2115.PNG", "IMG_2116.PNG", "IMG_2118.PNG"]

LISTING = dict(
    product_name="304 Stainless Steel Gua Sha Board Set (2 pcs)",
    category="Beauty",
    price=1.6,
    moq_qty=50,
    stock_qty=1500,
    description=(
        "Two mirror-polished gua sha boards in 304 stainless steel: a heart "
        "shape for the jawline, cheeks and under-eye area, and a large "
        "fan shape for the neck, shoulders and body.\n\n"
        "Steel stays cool against the skin, which helps calm puffiness "
        "after a facial massage. Smooth rounded edges glide easily with "
        "face oil or serum. Unlike stone boards it won't chip or crack if "
        "dropped, and it is easy to wash and disinfect between uses, "
        "making it a good fit for salons and spas.\n\n"
        "Specifications:\n"
        "- Set includes: 1 heart-shaped board, 1 large fan-shaped board\n"
        "- Large board size: approx. 8.5 x 6.5 cm\n"
        "- Material: 304 food-grade stainless steel, mirror polished\n"
        "- Thickness: about 3 mm\n"
        "- Rust-resistant, reusable, easy to clean"
    ),
    sample_testing_enabled=True,
    sample_price=2.5,
    colors=[{"name": "Silver", "hex": "#C0C0C0"}],
    weight="0.1 kg per set",
    origin="China",
    grade="304 stainless steel",
    packaging="Velvet pouch per set, 200 sets per carton",
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
