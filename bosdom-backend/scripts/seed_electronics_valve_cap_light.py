"""One-off: adds the LED valve cap wheel light Electronics listing (photos from
bosdom/assets/More pic /eletronic 2/) to Heng Visal's "Home 67 sep" shop.

Photos are converted to WebP and uploaded to Supabase Storage like any
listing photo. Safe to re-run: skips if the shop already has the listing.

    uv run python scripts/seed_electronics_valve_cap_light.py --dry-run
    uv run python scripts/seed_electronics_valve_cap_light.py
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
    Path(__file__).resolve().parents[2] / "bosdom" / "assets" / "More pic " / "eletronic 2"
)
# Cover first: the glowing wheel ring, then the pack contents and the
# exploded view.
PHOTOS = ["IMG_2124.PNG", "IMG_2126.PNG", "IMG_2125.PNG"]

LISTING = dict(
    product_name="LED Tire Valve Cap Wheel Lights (2 pcs + Spare Batteries)",
    category="Electronics",
    price=2.2,
    moq_qty=50,
    stock_qty=1000,
    description=(
        "Screw-on LED lights that replace the valve caps on your tires. "
        "Once you are moving, the light spins with the wheel and draws a "
        "full glowing ring around the rim, which looks great and makes "
        "scooters, e-bikes and motorbikes much easier to see from the "
        "side at night.\n\n"
        "Motion activated: the high-speed version lights up from about "
        "28 km/h, the faster you ride the fuller the ring, and it turns "
        "off by itself as soon as you stop. The clear shell and metal body "
        "are waterproof and dustproof, and each set comes with spare "
        "button-cell batteries. Keep the clear film on the battery surface "
        "when replacing them.\n\n"
        "Specifications:\n"
        "- In the box: 2 valve cap lights + 2 sets of spare batteries\n"
        "- Activation: motion sensor, lights at approx. 28-120 km/h\n"
        "- Fits: standard Schrader (car/motorbike type) valves\n"
        "- Body: aluminium alloy base with clear PC lens\n"
        "- Waterproof and dustproof\n"
        "- Power: replaceable button-cell batteries"
    ),
    sample_testing_enabled=True,
    sample_price=3.5,
    colors=[
        {"name": "Ice Blue", "hex": "#4FA3FF"},
        {"name": "Purple", "hex": "#B04DFF"},
    ],
    weight="30g per pair",
    origin="China",
    grade="Grade A",
    packaging="Retail box per pair, 200 pairs per carton",
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
