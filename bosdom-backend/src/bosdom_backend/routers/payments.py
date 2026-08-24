import stripe
from fastapi import APIRouter
from pydantic import BaseModel, Field

from ..config import settings

stripe.api_key = settings.stripe_secret_key

router = APIRouter(prefix="/payments", tags=["payments"])


class CreatePaymentIntentRequest(BaseModel):
    amount: float = Field(gt=0, description="Amount in dollars")
    currency: str = "usd"


class CreatePaymentIntentResponse(BaseModel):
    client_secret: str
    publishable_key: str


@router.post("/intent", response_model=CreatePaymentIntentResponse)
def create_payment_intent(body: CreatePaymentIntentRequest) -> CreatePaymentIntentResponse:
    intent = stripe.PaymentIntent.create(
        amount=round(body.amount * 100),
        currency=body.currency,
        automatic_payment_methods={"enabled": True},
    )
    return CreatePaymentIntentResponse(
        client_secret=intent.client_secret,
        publishable_key=settings.stripe_publishable_key,
    )
