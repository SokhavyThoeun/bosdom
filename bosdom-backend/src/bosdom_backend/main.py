from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

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
    profile,
    receipts,
    sample_orders,
    shop,
    wishlist,
)

app = FastAPI(title="Bosdom Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(receipts.router)
app.include_router(orders.router)
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

_media_dir = Path(__file__).resolve().parent / "media"
_media_dir.mkdir(exist_ok=True)
app.mount("/media", StaticFiles(directory=_media_dir), name="media")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
