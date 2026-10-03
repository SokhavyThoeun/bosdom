import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.concurrency import run_in_threadpool
from sqlalchemy import text
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

from . import storage
from .db import SessionLocal, engine
from .models import BuyerAddress, PaywayPayment, StoreAddress, UserNotification
from .routers import (
    admin,
    ads_consent,
    buyer_addresses,
    cart,
    chat,
    co_buy,
    disputes,
    listings,
    marketing_consent,
    notifications,
    orders,
    payments,
    profile,
    receipts,
    sample_orders,
    shop,
    store_addresses,
    wishlist,
)

# The notifications/PayWay/store-address/buyer-address tables are new; create them if the
# SQL migrations haven't been applied yet so they work instead of erroring
# (no-op once they exist).
UserNotification.__table__.create(bind=engine, checkfirst=True)
PaywayPayment.__table__.create(bind=engine, checkfirst=True)
StoreAddress.__table__.create(bind=engine, checkfirst=True)
BuyerAddress.__table__.create(bind=engine, checkfirst=True)

# New columns on existing tables (mirrors supabase/migrations/
# 20261002110000_order_shipping_and_co_buy_orders.sql and
# 20261002120000_paid_sample_orders.sql and
# 20261002130000_buyer_refunds.sql and
# 20261002140000_co_buy_deadlines.sql and
# 20261002150000_per_seller_shipping.sql and
# 20261003100000_listing_stock.sql); idempotent.
if engine.dialect.name == "postgresql":
    with engine.begin() as conn:
        conn.execute(
            text(
                "alter table escrow_orders"
                " add column if not exists shipping_fee double precision"
                " not null default 0,"
                " add column if not exists co_buy_participant_id text,"
                " add column if not exists is_sample boolean not null default false,"
                " add column if not exists escrow_fee double precision"
                " not null default 0,"
                " add column if not exists refund_amount double precision,"
                " add column if not exists refund_sent_at timestamptz,"
                " add column if not exists stock_taken boolean not null default false"
            )
        )
        conn.execute(
            text(
                "create index if not exists escrow_orders_co_buy_participant_id_idx"
                " on escrow_orders (co_buy_participant_id)"
            )
        )
        conn.execute(
            text(
                "alter table co_buy_deal_pools"
                " add column if not exists ends_at timestamptz,"
                " add column if not exists status text not null default 'open'"
            )
        )
        conn.execute(
            text(
                "alter table payway_payments add column if not exists"
                " shipping_fee double precision not null default 0,"
                " add column if not exists refund_sent_at timestamptz,"
                " add column if not exists shipping_shares json"
                " not null default '{}'::json"
            )
        )
storage.ensure_buckets()

# How often pending PayWay payments are re-checked in the background. KHQR
# codes live 5 minutes and card pages 15, so this catches every payment well
# within its lifetime.
_PAYMENT_SYNC_INTERVAL_SECONDS = 30

_log = logging.getLogger(__name__)


def _sync_payments_once() -> None:
    db = SessionLocal()
    try:
        payments.sync_pending_payments(db)
        # Same timer closes co-buy deals whose time ran out.
        co_buy.settle_due_pools(db)
    finally:
        db.close()


async def _payment_sync_loop() -> None:
    """Settles payments PayWay approved but nobody asked about — the buyer
    closed the app, and without a public callback URL PayWay can't tell us."""
    while True:
        await asyncio.sleep(_PAYMENT_SYNC_INTERVAL_SECONDS)
        try:
            await run_in_threadpool(_sync_payments_once)
        except Exception:  # noqa: BLE001 — keep the loop alive
            _log.exception("Background payment sync failed")


@asynccontextmanager
async def _lifespan(_: FastAPI):
    task = asyncio.create_task(_payment_sync_loop())
    try:
        yield
    finally:
        task.cancel()


app = FastAPI(title="Bosdom Backend", lifespan=_lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(receipts.router)
app.include_router(orders.router)
app.include_router(payments.router)
app.include_router(disputes.router)
app.include_router(co_buy.router)
app.include_router(wishlist.router)
app.include_router(cart.router)
app.include_router(chat.router)
app.include_router(notifications.router)
app.include_router(ads_consent.router)
app.include_router(marketing_consent.router)
app.include_router(profile.router)
app.include_router(store_addresses.router)
app.include_router(buyer_addresses.router)
app.include_router(shop.router)
app.include_router(listings.router)
app.include_router(sample_orders.router)
app.include_router(admin.router)

@app.get("/media/{path:path}")
def media(path: str) -> RedirectResponse:
    """Uploads live in Supabase Storage. Private files (KYC, dispute
    evidence) are stored as `/media/private/...` and get a short-lived signed
    URL; any leftover relative public path goes to its public URL."""
    if path.startswith("private/"):
        return RedirectResponse(storage.signed_url(path.removeprefix("private/")))
    return RedirectResponse(storage.public_url(path))


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
