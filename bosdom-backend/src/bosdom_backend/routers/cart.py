from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

router = APIRouter(prefix="/cart", tags=["cart"])


class CartLineOut(BaseModel):
    item_id: str
    quantity: int


class CartOut(BaseModel):
    lines: list[CartLineOut]


class AddRequest(BaseModel):
    item_id: str
    quantity: int = Field(gt=0)


class UpdateRequest(BaseModel):
    quantity: int = Field(gt=0)


class RemoveManyRequest(BaseModel):
    item_ids: list[str]


# In-memory store, mirroring the other routers' lack of a persistence layer.
_cart_lines: dict[str, int] = {}


def _cart_out() -> CartOut:
    return CartOut(lines=[CartLineOut(item_id=k, quantity=v) for k, v in _cart_lines.items()])


@router.get("", response_model=CartOut)
def get_cart() -> CartOut:
    return _cart_out()


@router.post("/items", response_model=CartOut)
def add_item(payload: AddRequest) -> CartOut:
    _cart_lines[payload.item_id] = _cart_lines.get(payload.item_id, 0) + payload.quantity
    return _cart_out()


@router.patch("/items/{item_id}", response_model=CartOut)
def update_item(item_id: str, payload: UpdateRequest) -> CartOut:
    if item_id not in _cart_lines:
        raise HTTPException(status_code=404, detail="Item not in cart")
    _cart_lines[item_id] = payload.quantity
    return _cart_out()


@router.delete("/items/{item_id}", response_model=CartOut)
def remove_item(item_id: str) -> CartOut:
    _cart_lines.pop(item_id, None)
    return _cart_out()


@router.post("/items/remove-many", response_model=CartOut)
def remove_many(payload: RemoveManyRequest) -> CartOut:
    for item_id in payload.item_ids:
        _cart_lines.pop(item_id, None)
    return _cart_out()
