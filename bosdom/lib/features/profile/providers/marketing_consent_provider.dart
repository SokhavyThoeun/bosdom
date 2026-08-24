import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/device_identity_provider.dart';
import '../models/marketing_consent.dart';
import '../services/marketing_consent_service.dart';

class MarketingConsentNotifier extends AsyncNotifier<MarketingConsent> {
  @override
  Future<MarketingConsent> build() async {
    final userId = await ref.watch(deviceUserIdProvider.future);
    return MarketingConsentService.fetch(userId);
  }

  Future<void> save(MarketingConsent consent) async {
    final previous = state.value;
    state = AsyncData(consent);

    try {
      final userId = await ref.read(deviceUserIdProvider.future);
      final saved = await MarketingConsentService.save(userId, consent);
      state = AsyncData(saved);
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }
}

final marketingConsentProvider =
    AsyncNotifierProvider<MarketingConsentNotifier, MarketingConsent>(
      MarketingConsentNotifier.new,
    );
