import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../models/sample_order.dart';
import '../services/sample_order_service.dart';

class SampleGateNotifier extends AsyncNotifier<SampleEligibility> {
  @override
  Future<SampleEligibility> build() => SampleOrderService.fetchEligibility();

  /// Requests a sample of [product]. Mock/demo products (see
  /// [Product.isRealListing]) have no backend listing row to order against,
  /// so the request is simulated locally instead — it still applies the
  /// same 3-day cooldown as a real order.
  ///
  /// Throws [SampleCooldownException] if the buyer is still within the
  /// backend's 3-day cooldown, or [SampleOrderException] for any other
  /// failure — callers should catch both and surface them to the user
  /// rather than letting them propagate.
  Future<SampleOrder> requestSample(Product product) async {
    final order = product.isRealListing
        ? await SampleOrderService.requestSample(product.id)
        : _demoSampleOrder(product);
    state = AsyncData(
      SampleEligibility(
        eligible: false,
        eligibleAt: order.createdAt.add(const Duration(days: 3)),
        lastSampleOrder: order,
      ),
    );
    return order;
  }

  SampleOrder _demoSampleOrder(Product product) {
    final now = DateTime.now();
    return SampleOrder(
      id: 'demo-${now.microsecondsSinceEpoch}',
      listingId: product.id,
      sellerId: product.sellerId ?? 'demo-seller',
      productName: product.name,
      price: product.samplePriceValue,
      status: 'requested',
      createdAt: now,
    );
  }
}

final sampleGateProvider =
    AsyncNotifierProvider<SampleGateNotifier, SampleEligibility>(
      SampleGateNotifier.new,
    );
