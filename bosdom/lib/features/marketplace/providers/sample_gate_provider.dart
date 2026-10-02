import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sample_order.dart';
import '../services/sample_order_service.dart';

/// Whether the buyer may buy a sample now (one every 3 days). Samples are
/// bought as paid orders at checkout, which refreshes this once paid.
class SampleGateNotifier extends AsyncNotifier<SampleEligibility> {
  @override
  Future<SampleEligibility> build() => SampleOrderService.fetchEligibility();
}

final sampleGateProvider =
    AsyncNotifierProvider<SampleGateNotifier, SampleEligibility>(
      SampleGateNotifier.new,
    );
