from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/wishlist", tags=["wishlist"])


class WishlistOut(BaseModel):
    item_ids: list[str]


class ToggleRequest(BaseModel):
    item_id: str


class ToggleOut(BaseModel):
    item_id: str
    in_wishlist: bool


# In-memory store, mirroring the other routers' lack of a persistence layer.
_wishlist_ids: set[str] = set()


@router.get("", response_model=WishlistOut)
def get_wishlist() -> WishlistOut:
    return WishlistOut(item_ids=sorted(_wishlist_ids))


@router.post("/toggle", response_model=ToggleOut)
def toggle_wishlist(payload: ToggleRequest) -> ToggleOut:
    if payload.item_id in _wishlist_ids:
        _wishlist_ids.remove(payload.item_id)
        in_wishlist = False
    else:
        _wishlist_ids.add(payload.item_id)
        in_wishlist = True
    return ToggleOut(item_id=payload.item_id, in_wishlist=in_wishlist)
