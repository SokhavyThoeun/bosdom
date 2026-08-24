from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from .notifications import NotificationTarget, push_notification

router = APIRouter(prefix="/co-buy", tags=["co-buy"])


class CoBuySession(BaseModel):
    id: str
    product_name: str
    seller_name: str
    current_qty: int
    target_qty: int
    unit_label: str
    min_order_qty: int
    retailers_joined: int
    time_left: str
    original_price: float
    price: float
    joined: bool

    @property
    def is_full(self) -> bool:
        return self.current_qty >= self.target_qty


class CoBuySessionOut(BaseModel):
    id: str
    product_name: str
    seller_name: str
    current_qty: int
    target_qty: int
    unit_label: str
    min_order_qty: int
    retailers_joined: int
    time_left: str
    original_price: float
    price: float
    joined: bool
    is_full: bool

    @classmethod
    def from_session(cls, session: CoBuySession) -> "CoBuySessionOut":
        return cls(**session.model_dump(), is_full=session.is_full)


# In-memory example data mirroring the Flutter app's mock provider —
# two sessions still filling, two already at target (one joined, one not).
_sessions: dict[str, CoBuySession] = {
    s.id: s
    for s in [
        CoBuySession(
            id="rice-50kg",
            product_name="Jasmine Rice Premium 50kg Bulk Bag",
            seller_name="Mekong Harvest Wholesaler",
            current_qty=340,
            target_qty=500,
            unit_label="kg",
            min_order_qty=20,
            retailers_joined=6,
            time_left="2 days left",
            original_price=45.00,
            price=38.50,
            joined=True,
        ),
        CoBuySession(
            id="coconut-oil-5l",
            product_name="Coconut Oil 5L",
            seller_name="Phnom Penh Agri-Trade",
            current_qty=8,
            target_qty=15,
            unit_label="units",
            min_order_qty=2,
            retailers_joined=3,
            time_left="18 hours left",
            original_price=24.00,
            price=19.80,
            joined=False,
        ),
        CoBuySession(
            id="fish-sauce-12pack",
            product_name="Fish Sauce 12-pack",
            seller_name="Battambang Food Co.",
            current_qty=30,
            target_qty=30,
            unit_label="packs",
            min_order_qty=4,
            retailers_joined=9,
            time_left="Target reached",
            original_price=18.50,
            price=14.20,
            joined=True,
        ),
        CoBuySession(
            id="palm-sugar-10kg",
            product_name="Palm Sugar 10kg Bulk Pack",
            seller_name="Kampong Speu Palm Farms",
            current_qty=25,
            target_qty=25,
            unit_label="bags",
            min_order_qty=5,
            retailers_joined=8,
            time_left="Target reached",
            original_price=32.00,
            price=26.50,
            joined=False,
        ),
    ]
}


@router.get("/sessions", response_model=list[CoBuySessionOut])
def list_sessions() -> list[CoBuySessionOut]:
    return [CoBuySessionOut.from_session(s) for s in _sessions.values()]


@router.get("/sessions/{session_id}", response_model=CoBuySessionOut)
def get_session(session_id: str) -> CoBuySessionOut:
    session = _sessions.get(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Co-buy session not found")
    return CoBuySessionOut.from_session(session)


@router.post("/sessions/{session_id}/toggle-join", response_model=CoBuySessionOut)
def toggle_join(session_id: str) -> CoBuySessionOut:
    session = _sessions.get(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Co-buy session not found")

    if session.joined:
        session.joined = False
        session.current_qty = max(0, session.current_qty - 1)
        session.retailers_joined = max(0, session.retailers_joined - 1)
    else:
        if session.is_full:
            raise HTTPException(status_code=409, detail="Co-buy session is full")
        was_full = session.is_full
        session.joined = True
        session.current_qty = min(session.target_qty, session.current_qty + 1)
        session.retailers_joined += 1

        if not was_full and session.is_full:
            push_notification(
                category="co_buy",
                title="Co-buy target reached",
                body=f"{session.product_name} hit its group buy target — checkout closes soon.",
                target=NotificationTarget(
                    route="coBuyDetail", params={"id": session.id}
                ),
            )

    return CoBuySessionOut.from_session(session)
