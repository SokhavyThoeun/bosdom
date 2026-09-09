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
///   carry more than ~20kg.
/// - **J&T Express** uses the tiered "first kg + additional kg" pricing
///   every J&T market runs, with a higher tier once a parcel leaves its
///   origin province. In Cambodia it also handles heavier cargo-style
///   shipments in practice, so — unlike Grab's motorbike-limited 20kg —
///   there's no weight ceiling here; the per-kg tier just keeps scaling.
/// - **Vireak Buntham Express** grew out of Cambodia's national bus
///   network, so its parcel service is priced like bus cargo: a flat rate
///   per weight bracket per route, higher for inter-provincial routes.
///   Because it rides in a bus's cargo hold rather than a courier bag, it
///   has no practical weight ceiling — it's the only one of the three that
///   can move a full wholesale pallet.
library;

const kGrabExpressCarrier = 'Grab Express';
const kJtExpressCarrier = 'J&T Express';
const kVireakBunthamCarrier = 'Vireak Buntham Express';

class ShippingQuote {
  const ShippingQuote({required this.fee, required this.etaLabel});

  final double fee;
  final String etaLabel;
}

/// Returns `null` when [carrier] genuinely can't service this shipment —
/// either the route (Grab Express is Phnom Penh same-city only) or the
/// weight (Grab's motorbike network has a real ~20kg ceiling; J&T and
/// Vireak Buntham have none).
ShippingQuote? estimateShippingFee({
  required String carrier,
  required double weightKg,
  required String originProvince,
  required String destinationProvince,
}) {
  final sameProvince =
      originProvince.trim().toLowerCase() ==
      destinationProvince.trim().toLowerCase();

  switch (carrier) {
    case kGrabExpressCarrier:
      final isPhnomPennRun =
          sameProvince && originProvince.trim().toLowerCase() == 'phnom penh';
      if (!isPhnomPennRun || weightKg > 20) return null;
      const baseFare = 1.50;
      const includedKg = 3.0;
      const perExtraKg = 0.35;
      final fee =
          baseFare +
          (weightKg > includedKg ? (weightKg - includedKg) * perExtraKg : 0);
      return ShippingQuote(fee: fee, etaLabel: 'Same-day · Phnom Penh only');

    case kJtExpressCarrier:
      final firstKgRate = sameProvince ? 1.80 : 2.80;
      final extraKgRate = sameProvince ? 0.40 : 0.60;
      final fee =
          firstKgRate + (weightKg > 1 ? (weightKg - 1) * extraKgRate : 0);
      return ShippingQuote(
        fee: fee,
        etaLabel: sameProvince ? '1-2 days' : '2-4 days',
      );

    case kVireakBunthamCarrier:
      final double fee;
      if (weightKg <= 5) {
        fee = sameProvince ? 2.50 : 4.00;
      } else if (weightKg <= 10) {
        fee = sameProvince ? 4.00 : 6.00;
      } else if (weightKg <= 20) {
        fee = sameProvince ? 6.50 : 9.50;
      } else {
        final bracketBase = sameProvince ? 6.50 : 9.50;
        fee = bracketBase + (weightKg - 20) * 0.35;
      }
      return ShippingQuote(
        fee: fee,
        etaLabel: sameProvince
            ? '1-2 days · bus network'
            : '2-3 days · bus network',
      );
  }
  return null;
}
