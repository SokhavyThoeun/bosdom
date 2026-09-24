"""ABA PayWay client: KHQR purchase, hosted card checkout, Check Transaction.

Docs: https://developer.payway.com.kh — every request carries an
HMAC-SHA512 (Base64) `hash` over its fields concatenated in a fixed,
endpoint-specific order, keyed with the merchant's API key.
"""

import base64
import hashlib
import hmac
import json
from dataclasses import dataclass
from datetime import datetime, timezone

import httpx

from .config import settings

_TIMEOUT = httpx.Timeout(15.0)

# Field order the Purchase API hashes over (empty string for unset fields).
_PURCHASE_HASH_ORDER = (
    "req_time",
    "merchant_id",
    "tran_id",
    "amount",
    "items",
    "shipping",
    "firstname",
    "lastname",
    "email",
    "phone",
    "type",
    "payment_option",
    "return_url",
    "cancel_url",
    "continue_success_url",
    "return_deeplink",
    "currency",
    "custom_fields",
    "return_params",
    "payout",
    "lifetime",
    "additional_params",
    "google_pay_token",
    "skip_success_page",
)

# Check Transaction `payment_status_code` values.
STATUS_APPROVED = 0
STATUS_PENDING = 2
STATUS_DECLINED = 3
STATUS_REFUNDED = 4
STATUS_CANCELLED = 7


class PayWayError(Exception):
    pass


@dataclass
class KhqrCheckout:
    qr_string: str
    deeplink: str


@dataclass
class TransactionStatus:
    code: int
    status: str
    total_amount: float
    apv: str


def is_configured() -> bool:
    return bool(settings.payway_merchant_id and settings.payway_api_key)


def is_sandbox() -> bool:
    return "sandbox" in settings.payway_base_url


def _req_time() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S")


def _sign(message: str) -> str:
    digest = hmac.new(
        settings.payway_api_key.encode(), message.encode(), hashlib.sha512
    ).digest()
    return base64.b64encode(digest).decode()


def _b64(value: str) -> str:
    return base64.b64encode(value.encode()).decode()


def _status_of(body: dict) -> tuple[str, str]:
    status = body.get("status") or {}
    return str(status.get("code", "")), str(status.get("message", ""))


def create_khqr(
    tran_id: str,
    amount: float,
    *,
    currency: str = "USD",
    lifetime_minutes: int = 5,
    items: list[dict] | None = None,
    callback_url: str | None = None,
) -> KhqrCheckout:
    """Opens a PayWay transaction payable by KHQR and returns the QR payload
    plus the ABA Mobile deeplink for it."""
    if not is_configured():
        raise PayWayError("PayWay is not configured")

    fields = {
        "req_time": _req_time(),
        "merchant_id": settings.payway_merchant_id,
        "tran_id": tran_id,
        "amount": f"{amount:.2f}",
        "payment_option": "abapay_khqr_deeplink",
        "currency": currency,
        "lifetime": str(lifetime_minutes),
    }
    if items:
        fields["items"] = _b64(json.dumps(items))
    if callback_url:
        fields["return_url"] = _b64(callback_url)
    fields["hash"] = _sign("".join(fields.get(k, "") for k in _PURCHASE_HASH_ORDER))

    try:
        # Multipart form, as the Purchase API expects. A rejected request
        # comes back as a 302 to `/checkout/<base64 JSON error>`, so
        # redirects are read, not followed.
        response = httpx.post(
            purchase_url(),
            files={k: (None, v) for k, v in fields.items()},
            timeout=_TIMEOUT,
            follow_redirects=False,
        )
    except httpx.HTTPError as e:
        raise PayWayError(f"PayWay unreachable: {e}") from e

    if response.is_redirect:
        encoded = response.headers.get("location", "").rsplit("/", 1)[-1]
        try:
            body = json.loads(base64.b64decode(encoded + "=" * (-len(encoded) % 4)))
        except ValueError:
            body = {}
        code, message = _status_of(body)
        raise PayWayError(f"PayWay rejected the payment ({code}): {message}")

    try:
        body = response.json()
    except ValueError as e:
        raise PayWayError(f"Unexpected PayWay response ({response.status_code})") from e
    code, message = _status_of(body)
    if code not in ("0", "00") or not body.get("qrString"):
        raise PayWayError(f"PayWay rejected the payment ({code}): {message}")
    return KhqrCheckout(
        qr_string=body["qrString"], deeplink=body.get("abapay_deeplink", "")
    )


def purchase_url() -> str:
    return f"{settings.payway_base_url}/api/payment-gateway/v1/payments/purchase"


def card_checkout_fields(
    tran_id: str,
    amount: float,
    *,
    success_url: str,
    cancel_url: str,
    currency: str = "USD",
    lifetime_minutes: int = 15,
    callback_url: str | None = None,
) -> dict[str, str]:
    """Signed Purchase API fields for PayWay's hosted card page. Unlike KHQR
    these aren't sent from here: the buyer's WebView posts them, so the card
    details are typed into PayWay's page and never touch this app."""
    if not is_configured():
        raise PayWayError("PayWay is not configured")

    fields = {
        "req_time": _req_time(),
        "merchant_id": settings.payway_merchant_id,
        "tran_id": tran_id,
        "amount": f"{amount:.2f}",
        "payment_option": "cards",
        "cancel_url": cancel_url,
        "continue_success_url": success_url,
        "currency": currency,
        "lifetime": str(lifetime_minutes),
        # Straight to `continue_success_url`, where the app's WebView closes.
        "skip_success_page": "1",
    }
    if callback_url:
        fields["return_url"] = _b64(callback_url)
    fields["hash"] = _sign("".join(fields.get(k, "") for k in _PURCHASE_HASH_ORDER))
    # Not part of the hash. Without it the sandbox profile (QR API on by
    # default) ignores `cards` and answers with KHQR JSON instead of the
    # card page.
    fields["payment_gate"] = "0"
    return fields


def check_transaction(tran_id: str) -> TransactionStatus:
    """Asks PayWay for a transaction's current status — the source of truth
    for whether a payment actually went through."""
    if not is_configured():
        raise PayWayError("PayWay is not configured")

    req_time = _req_time()
    merchant_id = settings.payway_merchant_id
    payload = {
        "req_time": req_time,
        "merchant_id": merchant_id,
        "tran_id": tran_id,
        "hash": _sign(req_time + merchant_id + tran_id),
    }
    try:
        response = httpx.post(
            f"{settings.payway_base_url}/api/payment-gateway/v1/payments/check-transaction-2",
            json=payload,
            timeout=_TIMEOUT,
        )
        body = response.json()
    except (httpx.HTTPError, ValueError) as e:
        raise PayWayError(f"PayWay unreachable: {e}") from e

    code, message = _status_of(body)
    data = body.get("data")
    if code not in ("0", "00") or not isinstance(data, dict):
        raise PayWayError(f"Check transaction failed ({code}): {message}")
    return TransactionStatus(
        code=int(data.get("payment_status_code", STATUS_PENDING)),
        status=str(data.get("payment_status", "")),
        total_amount=float(data.get("total_amount") or 0),
        apv=str(data.get("apv") or ""),
    )
