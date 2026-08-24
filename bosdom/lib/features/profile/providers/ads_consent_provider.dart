import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/device_identity_provider.dart';
import '../models/ads_consent.dart';
import '../services/ads_consent_service.dart';

class AdsConsentNotifier extends AsyncNotifier<AdsConsent> {
  @override
  Future<AdsConsent> build() async {
    final userId = await ref.watch(deviceUserIdProvider.future);
    return AdsConsentService.fetch(userId);
  }

  Future<void> save(AdsConsent consent) async {
    final previous = state.value;
    state = AsyncData(consent);

    try {
      final userId = await ref.read(deviceUserIdProvider.future);
      final saved = await AdsConsentService.save(userId, consent);
      state = AsyncData(saved);
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }
}

final adsConsentProvider = AsyncNotifierProvider<AdsConsentNotifier, AdsConsent>(
  AdsConsentNotifier.new,
);
