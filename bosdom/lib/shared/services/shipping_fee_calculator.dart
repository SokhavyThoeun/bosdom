/// Real-world Cambodia parcel-delivery pricing.
///
/// None of the three carriers below publish an official tariff sheet, so
/// this models each company's actual pricing *mechanism* and real service
/// constraints instead of a single made-up flat number:
///
/// - **Grab Express** prices like Grab's ride-hailing product: a small
///   base fare that covers a light parcel plus a per-kg surcharge, carried
///   by a motorbike. In Cambodia it only runs same-city trips — Phnom Penh
///   pickup to a Phnom Penh address — and a motorbike can't realistically
///   carry more than ~20kg. Priced by road distance from Phnom Penh (either
///   direction) plus a weight surcharge, and always paid by the buyer to
///   the rider on delivery, never at checkout.
/// - **J&T Express** uses the tiered "first kg + additional kg" pricing
///   every J&T market runs, with a higher tier once a parcel leaves its
///   origin province. In Cambodia it also handles heavier cargo-style
///   shipments in practice, so — unlike Grab's motorbike-limited 20kg —
///   there's no weight ceiling here; the per-kg tier just keeps scaling.
/// - **Vireak Buntham Logistic** grew out of Cambodia's national bus
///   network, so its parcel service is priced like bus cargo: a flat rate
///   per weight bracket per route, higher for inter-provincial routes.
///   Because it rides in a bus's cargo hold rather than a courier bag, it
///   has no practical weight ceiling — it's the only one of the three that
///   can move a full wholesale pallet.
library;

const kGrabExpressCarrier = 'Grab Express';
const kJtExpressCarrier = 'J&T Express';
const kVetLogisticCarrier = 'Vireak Buntham Logistic';

class ShippingQuote {
  const ShippingQuote({
    required this.fee,
    required this.etaLabel,
    this.payOnDelivery = false,
  });

  final double fee;
  final String etaLabel;

  /// True when the buyer pays [fee] to the courier on receipt, so it is
  /// shown as an estimate but excluded from the amount charged at checkout.
  final bool payOnDelivery;
}

/// Approximate road distance (km) between Phnom Penh and each province
/// capital, used for distance-based courier pricing in either direction.
const Map<String, double> kKmFromPhnomPenh = {
  'phnom penh': 0,
  'kandal': 25,
  'kampong speu': 48,
  'takeo': 75,
  'prey veng': 90,
  'kampong chhnang': 92,
  'kampong cham': 120,
  'svay rieng': 122,
  'tboung khmum': 140,
  'tbong khmum': 140,
  'kampong thom': 148,
  'kampot': 148,
  'kep': 168,
  'pursat': 185,
  'preah sihanouk': 230,
  'battambang': 290,
  'preah vihear': 300,
  'siem reap': 315,
  'kratie': 340,
  'banteay meanchey': 360,
  'mondulkiri': 380,
  'pailin': 380,
  'koh kong': 300,
  'oddar meanchey': 420,
  'stung treng': 450,
  'ratanakiri': 590,
};

/// Returns `null` when [carrier] genuinely can't service this shipment —
/// either the route (Grab Express only runs to/from Phnom Penh) or the
/// weight (Grab's motorbike network has a real ~20kg ceiling; J&T and
/// VET have none).
ShippingQuote? estimateShippingFee({
  required String carrier,
  required double weightKg,
  required String originProvince,
  required String destinationProvince,
}) {
  final km = roadKmBetween(originProvince, destinationProvince);
  final weight = weightKg < 1 ? 1.0 : weightKg;

  switch (carrier) {
    case kGrabExpressCarrier:
      // Runs only to/from Phnom Penh, and only what fits on a motorbike.
      final origin = originProvince.trim().toLowerCase();
      final destination = destinationProvince.trim().toLowerCase();
      final touchesPhnomPenh =
          origin == 'phnom penh' || destination == 'phnom penh';
      if (!touchesPhnomPenh || km == null || weightKg > 20) return null;
      const baseFare = 1.50;
      const includedKg = 3.0;
      const perExtraKg = 0.35;
      const perKm = 0.12;
      final fee =
          baseFare +
          km * perKm +
          (weightKg > includedKg ? (weightKg - includedKg) * perExtraKg : 0);
      return ShippingQuote(
        fee: fee,
        etaLabel: km == 0
            ? 'Same-day · Pay on delivery'
            : '${km <= 150 ? 'Next-day' : '1-2 days'} · Pay on delivery',
        payOnDelivery: true,
      );

    case kJtExpressCarrier:
      // "First kg + each additional kg", stepped up by delivery zone. The
      // same-city first kg is anchored to J&T Cambodia's published
      // "from 4,000 KHR" (~US$1.00); the farther zones are estimates.
      final zone = _zoneFor(km);
      final (firstKg, extraKg) = switch (zone) {
        _Zone.city => (1.00, 0.25),
        _Zone.near => (1.50, 0.40),
        _Zone.mid => (1.90, 0.50),
        _Zone.far => (2.40, 0.60),
      };
      final fee = firstKg + (weight - 1) * extraKg;
      return ShippingQuote(
        fee: fee,
        etaLabel: switch (zone) {
          _Zone.city => 'Next-day delivery · Within city',
          _Zone.near => '1-2 business days · Nearby provinces',
          _Zone.mid => '2-3 business days · Provincial delivery',
          _Zone.far => '3-4 business days · Long-distance route',
        },
      );

    case kVetLogisticCarrier:
      // Bus-cargo style: a flat rate per weight bracket, stepped up by
      // route zone, then a per-kg rate beyond the top bracket. Estimates.
      final zone = _zoneFor(km);
      // (≤5kg, ≤10kg, ≤20kg, ≤50kg, per kg above 50kg)
      final (b5, b10, b20, b50, perKgOver) = switch (zone) {
        _Zone.city => (2.00, 3.00, 4.50, 8.00, 0.12),
        _Zone.near => (2.50, 3.50, 5.50, 10.00, 0.15),
        _Zone.mid => (3.00, 4.50, 7.00, 13.00, 0.20),
        _Zone.far => (4.00, 6.00, 9.00, 17.00, 0.28),
      };
      final double fee;
      if (weightKg <= 5) {
        fee = b5;
      } else if (weightKg <= 10) {
        fee = b10;
      } else if (weightKg <= 20) {
        fee = b20;
      } else if (weightKg <= 50) {
        fee = b50;
      } else {
        fee = b50 + (weightKg - 50) * perKgOver;
      }
      return ShippingQuote(
        fee: fee,
        etaLabel: switch (zone) {
          _Zone.city => 'Same-day delivery · Within city',
          _Zone.near => '1-2 business days · Nearby provinces',
          _Zone.mid => '2-3 business days · Provincial delivery',
          _Zone.far => '3-4 business days · Long-distance route',
        },
      );
  }
  return null;
}

enum _Zone { city, near, mid, far }

_Zone _zoneFor(double? km) {
  if (km == null) return _Zone.far;
  if (km == 0) return _Zone.city;
  if (km <= 150) return _Zone.near;
  if (km <= 300) return _Zone.mid;
  return _Zone.far;
}

/// Approximate road distance between two provinces, routed through the
/// Phnom Penh hub (as J&T and bus cargo both are). `null` if either
/// province is unknown.
double? roadKmBetween(String from, String to) {
  final a = from.trim().toLowerCase();
  final b = to.trim().toLowerCase();
  if (a == b) return 0;
  final kmA = kKmFromPhnomPenh[a];
  final kmB = kKmFromPhnomPenh[b];
  if (kmA == null || kmB == null) return null;
  return kmA + kmB;
}

/// Best-effort parse of a seller's free-text weight (e.g. "25kg per bag",
/// "500 g", "1.5 lb") into kilograms. `null` when no weight is found.
double? parseWeightKg(String? text) {
  if (text == null) return null;
  final match = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(kgs?|kilograms?|grams?|gr|g|lbs?|pounds?|tons?|tonnes?|mt)\b',
    caseSensitive: false,
  ).firstMatch(text);
  if (match == null) return null;
  final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (value == null) return null;
  final unit = match.group(2)!.toLowerCase();
  if (unit.startsWith('kg') || unit.startsWith('kilo')) return value;
  if (unit.startsWith('lb') || unit.startsWith('pound')) return value * 0.4536;
  if (unit.startsWith('t') || unit == 'mt') return value * 1000;
  return value / 1000;
}
