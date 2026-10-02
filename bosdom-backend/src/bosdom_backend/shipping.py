"""Server-side shipping quotes, so checkout can't be told what shipping costs.

A line-for-line port of the app's `shared/services/shipping_fee_calculator.dart`
— keep the two in sync. See that file for how each carrier's pricing is
modelled.
"""

import re
from dataclasses import dataclass

GRAB_EXPRESS = "Grab Express"
JT_EXPRESS = "J&T Express"
VET_LOGISTIC = "Vireak Buntham Logistic"

# Checkout's carrier order — the first one that can serve a shipment is the
# default when the app doesn't say which was picked.
CARRIERS = (VET_LOGISTIC, JT_EXPRESS, GRAB_EXPRESS)

# Every seller ships from Phnom Penh (checkout's `_kOriginProvince`).
ORIGIN_PROVINCE = "Phnom Penh"

KM_FROM_PHNOM_PENH = {
    "phnom penh": 0,
    "kandal": 25,
    "kampong speu": 48,
    "takeo": 75,
    "prey veng": 90,
    "kampong chhnang": 92,
    "kampong cham": 120,
    "svay rieng": 122,
    "tboung khmum": 140,
    "tbong khmum": 140,
    "kampong thom": 148,
    "kampot": 148,
    "kep": 168,
    "pursat": 185,
    "preah sihanouk": 230,
    "battambang": 290,
    "preah vihear": 300,
    "siem reap": 315,
    "kratie": 340,
    "banteay meanchey": 360,
    "mondulkiri": 380,
    "pailin": 380,
    "koh kong": 300,
    "oddar meanchey": 420,
    "stung treng": 450,
    "ratanakiri": 590,
}


@dataclass(frozen=True)
class ShippingQuote:
    fee: float
    # The buyer pays the courier on receipt, so nothing is charged at checkout.
    pay_on_delivery: bool = False

    @property
    def charged(self) -> float:
        return 0.0 if self.pay_on_delivery else round(self.fee, 2)


def road_km_between(origin: str, destination: str) -> float | None:
    a, b = origin.strip().lower(), destination.strip().lower()
    if a == b:
        return 0
    km_a, km_b = KM_FROM_PHNOM_PENH.get(a), KM_FROM_PHNOM_PENH.get(b)
    if km_a is None or km_b is None:
        return None
    return km_a + km_b


def _zone(km: float | None) -> str:
    if km is None:
        return "far"
    if km == 0:
        return "city"
    if km <= 150:
        return "near"
    if km <= 300:
        return "mid"
    return "far"


def estimate(
    carrier: str, weight_kg: float, origin: str, destination: str
) -> ShippingQuote | None:
    """None when the carrier can't serve this weight/route at all."""
    km = road_km_between(origin, destination)
    weight = max(weight_kg, 1.0)

    if carrier == GRAB_EXPRESS:
        touches_pp = "phnom penh" in (origin.strip().lower(), destination.strip().lower())
        if not touches_pp or km is None or weight_kg > 20:
            return None
        extra = (weight_kg - 3.0) * 0.35 if weight_kg > 3.0 else 0
        return ShippingQuote(1.50 + km * 0.12 + extra, pay_on_delivery=True)

    if carrier == JT_EXPRESS:
        first_kg, extra_kg = {
            "city": (1.00, 0.25),
            "near": (1.50, 0.40),
            "mid": (1.90, 0.50),
            "far": (2.40, 0.60),
        }[_zone(km)]
        return ShippingQuote(first_kg + (weight - 1) * extra_kg)

    if carrier == VET_LOGISTIC:
        b5, b10, b20, b50, per_kg_over = {
            "city": (2.00, 3.00, 4.50, 8.00, 0.12),
            "near": (2.50, 3.50, 5.50, 10.00, 0.15),
            "mid": (3.00, 4.50, 7.00, 13.00, 0.20),
            "far": (4.00, 6.00, 9.00, 17.00, 0.28),
        }[_zone(km)]
        if weight_kg <= 5:
            fee = b5
        elif weight_kg <= 10:
            fee = b10
        elif weight_kg <= 20:
            fee = b20
        elif weight_kg <= 50:
            fee = b50
        else:
            fee = b50 + (weight_kg - 50) * per_kg_over
        return ShippingQuote(fee)

    return None


_WEIGHT_RE = re.compile(
    r"(\d+(?:[.,]\d+)?)\s*(kgs?|kilograms?|grams?|gr|g|lbs?|pounds?|tons?|tonnes?|mt)\b",
    re.IGNORECASE,
)


def parse_weight_kg(text: str | None) -> float | None:
    """Best-effort parse of a seller's free-text weight ("25kg per bag",
    "500 g", "1.5 lb") into kilograms."""
    if not text:
        return None
    match = _WEIGHT_RE.search(text)
    if match is None:
        return None
    value = float(match.group(1).replace(",", "."))
    unit = match.group(2).lower()
    if unit.startswith(("kg", "kilo")):
        return value
    if unit.startswith(("lb", "pound")):
        return value * 0.4536
    if unit.startswith("t") or unit == "mt":
        return value * 1000
    return value / 1000


def unit_weight_kg(weight: str | None, name: str) -> float:
    """Same fallback chain as the app's `Product.unitWeightKg`."""
    return parse_weight_kg(weight) or parse_weight_kg(name) or 1.0


def province_in(address: str) -> str | None:
    """The province named in a delivery address (the app writes
    "..., <Province>, Cambodia"), so shipping is priced to where the parcel
    actually goes. The last-mentioned match wins."""
    text = address.lower()
    best: tuple[int, str] | None = None
    for province in KM_FROM_PHNOM_PENH:
        at = text.rfind(province)
        if at >= 0 and (best is None or at > best[0]):
            best = (at, province)
    return best[1] if best else None


def quote(
    carrier: str | None, weight_kg: float, destination: str
) -> ShippingQuote | None:
    """The picked carrier's quote, or — when none was named (older app
    versions) — the first carrier that can serve it, like checkout's default."""
    if carrier:
        return estimate(carrier, weight_kg, ORIGIN_PROVINCE, destination)
    for name in CARRIERS:
        q = estimate(name, weight_kg, ORIGIN_PROVINCE, destination)
        if q is not None:
            return q
    return None
