import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sample_order.dart';
import '../services/sample_order_service.dart';

class SampleGateNotifier extends AsyncNotifier<SampleEligibility> {
  @override
  Future<SampleEligibility> build() => SampleOrderService.fetchEligibility();

  /// Requests a sample for [listingId]. Throws [SampleCooldownException] if
  /// the buyer is still within the backend's 3-day cooldown, or
  /// [SampleOrderException] for any other failure — callers should catch
  /// both and surface them to the user rather than letting them propagate.
  Future<SampleOrder> requestSample(String listingId) async {
    final order = await SampleOrderService.requestSample(listingId);
    state = AsyncData(
      SampleEligibility(
        eligible: false,
        eligibleAt: order.createdAt.add(const Duration(days: 3)),
        lastSampleOrder: order,
      ),
    );
    return order;
  }
}

final sampleGateProvider =
    AsyncNotifierProvider<SampleGateNotifier, SampleEligibility>(
      SampleGateNotifier.new,
    );
