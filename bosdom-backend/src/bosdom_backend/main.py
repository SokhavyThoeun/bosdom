from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

from . import storage
from .db import engine
from .models import PaywayPayment, UserNotification
from .routers import (
    admin,
    ads_consent,
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
    wishlist,
)

# The notifications/PayWay tables are new; create them if the SQL migrations
# haven't been applied yet so they work instead of erroring (no-op once they
# exist).
UserNotification.__table__.create(bind=engine, checkfirst=True)
PaywayPayment.__table__.create(bind=engine, checkfirst=True)
storage.ensure_buckets()

app = FastAPI(title="Bosdom Backend")

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
