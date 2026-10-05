"""One-off: opens a co-buy deal for the DIY face mask bowl set (the Beauty 1
listing, see seed_beauty_mask_bowl_set.py) in Heng Visal's "Home 67 sep" shop.

Reuses the listing's description, colors, specs and already-uploaded photos,
at a group price below the listing's. Safe to re-run: skips if the shop
already has an open deal for it.

    uv run python scripts/seed_co_buy_mask_bowl_set.py --dry-run
    uv run python scripts/seed_co_buy_mask_bowl_set.py
"""

import sys
from datetime import datetime, timezone

from bosdom_backend.db import SessionLocal
from bosdom_backend.models import CoBuyPool, Listing, Shop
from bosdom_backend.routers.co_buy import duration_of

SHOP_NAME = "Home 67 sep"
LISTING_NAME = "DIY Face Mask Bowl Set (5 pcs)"

DEAL = dict(
    price=0.65,
    original_price=0.9,
    target_qty=1000,
    unit_label="sets",
    per_unit_label="set",
    min_order_qty=20,
    time_left="1 week left",
    auto_renew=False,
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

        listing = (
            db.query(Listing)
            .filter(Listing.seller_id == shop.id, Listing.product_name == LISTING_NAME)
            .first()
        )
        if listing is None:
            sys.exit(f"No {LISTING_NAME!r} listing yet, run seed_beauty_mask_bowl_set.py first.")

        exists = (
            db.query(CoBuyPool)
            .filter(
                CoBuyPool.seller_id == shop.id,
                CoBuyPool.product_name == LISTING_NAME,
                CoBuyPool.status == "open",
            )
            .first()
        )
        if exists:
            print(f"Already an open deal ({exists.id}), nothing to do.")
            return

        print(f"Shop: {shop.shop_name} ({shop.id})")
        print(f"From listing {listing.id} with {len(listing.photo_urls)} photos")
        if dry_run:
            print(f"Would open deal: {LISTING_NAME} at ${DEAL['price']} ({DEAL['time_left']})")
            return

        pool = CoBuyPool(
            seller_id=shop.id,
            product_name=listing.product_name,
            category=listing.category,
            description=listing.description,
            ends_at=datetime.now(timezone.utc) + duration_of(DEAL["time_left"]),
            status="open",
            photo_urls=list(listing.photo_urls),
            sizes=list(listing.sizes or []),
            colors=list(listing.colors or []),
            weight=listing.weight,
            origin=listing.origin,
            grade=listing.grade,
            packaging=listing.packaging,
            **DEAL,
        )
        db.add(pool)
        db.commit()
        print(f"Opened deal {pool.id}: {pool.product_name}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
