"""One-off: fills `Order.courier` on orders paid before checkout started
recording which courier the buyer picked.

The pick wasn't stored, so it's inferred: the courier whose quote for the
order's weight/destination matches the shipping fee the buyer paid, else
checkout's default (the first courier that can serve it). Only orders with
no courier yet are touched, so it's safe to re-run.

    uv run python scripts/backfill_order_couriers.py --dry-run
    uv run python scripts/backfill_order_couriers.py
"""

import sys

from bosdom_backend import shipping
from bosdom_backend.db import SessionLocal
from bosdom_backend.models import CoBuyPool, Listing, Order


def infer_courier(db, order: Order) -> str | None:
    item = db.get(Listing, order.listing_id) or db.get(CoBuyPool, order.listing_id)
    unit = shipping.unit_weight_kg(
        item.weight if item else None, item.product_name if item else order.product_name
    )
    weight = unit * order.quantity
    destination = shipping.province_in(order.shipping_address) or shipping.ORIGIN_PROVINCE
    for carrier in shipping.CARRIERS:
        q = shipping.estimate(carrier, weight, shipping.ORIGIN_PROVINCE, destination)
        if q is not None and abs(q.charged - (order.shipping_fee or 0)) < 0.01:
            return carrier
    picked = shipping.quote(None, weight, destination)
    return picked[0] if picked else None


def main() -> None:
    dry_run = "--dry-run" in sys.argv
    with SessionLocal() as db:
        orders = (
            db.query(Order)
            .filter(Order.courier.is_(None), Order.status != "pending_payment")
            .all()
        )
        for order in orders:
            courier = infer_courier(db, order)
            print(f"{order.id}  {order.product_name!r}  ${order.shipping_fee:.2f} -> {courier}")
            if courier and not dry_run:
                order.courier = courier
        if not dry_run:
            db.commit()
        print(f"{len(orders)} order(s){' (dry run)' if dry_run else ' updated'}")


if __name__ == "__main__":
    main()
