from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .db import Base, engine
from .routers import (
    ads_consent,
    chat,
    co_buy,
    marketing_consent,
    notifications,
    orders,
    payments,
    receipts,
    wishlist,
)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Bosdom Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(payments.router)
app.include_router(receipts.router)
app.include_router(orders.router)
app.include_router(co_buy.router)
app.include_router(wishlist.router)
app.include_router(chat.router)
app.include_router(notifications.router)
app.include_router(ads_consent.router)
app.include_router(marketing_consent.router)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
