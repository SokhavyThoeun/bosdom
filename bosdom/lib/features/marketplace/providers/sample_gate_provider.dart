import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClaimedSample {
  const ClaimedSample({required this.productId, required this.productName});

  final String productId;
  final String productName;
}

const _kClaimedProductIdKey = 'sample_gate_claimed_product_id';
const _kClaimedProductNameKey = 'sample_gate_claimed_product_name';

class SampleGateNotifier extends AsyncNotifier<ClaimedSample?> {
  @override
  Future<ClaimedSample?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final productId = prefs.getString(_kClaimedProductIdKey);
    final productName = prefs.getString(_kClaimedProductNameKey);
    if (productId == null || productName == null) return null;
    return ClaimedSample(productId: productId, productName: productName);
  }

  Future<void> claimSample({
    required String productId,
    required String productName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kClaimedProductIdKey, productId);
    await prefs.setString(_kClaimedProductNameKey, productName);
    state = AsyncData(
      ClaimedSample(productId: productId, productName: productName),
    );
  }
}

final sampleGateProvider =
    AsyncNotifierProvider<SampleGateNotifier, ClaimedSample?>(
      SampleGateNotifier.new,
    );
