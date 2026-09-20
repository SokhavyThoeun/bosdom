import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop_profile.dart';
import '../services/shop_profile_service.dart';

class ShopProfileNotifier extends AsyncNotifier<ShopProfile> {
  @override
  Future<ShopProfile> build() => ShopProfileService.fetch();

  /// Re-fetches without flipping to a loading state, so the dashboard keeps
  /// showing the current shop while a pull-to-refresh is in flight.
  Future<void> refresh() async {
    state = AsyncData(await ShopProfileService.fetch());
  }

  Future<void> save(ShopProfile shop) async {
    final previous = state.value;
    state = AsyncData(shop);

    try {
      final saved = await ShopProfileService.save(shop);
      state = AsyncData(saved);
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> uploadLogo(File file) async {
    final updated = await ShopProfileService.uploadLogo(file);
    state = AsyncData(updated);
  }

  Future<void> uploadStorePhotos(List<File> files) async {
    final updated = await ShopProfileService.uploadStorePhotos(files);
    state = AsyncData(updated);
  }
}

final shopProfileProvider =
    AsyncNotifierProvider<ShopProfileNotifier, ShopProfile>(
      ShopProfileNotifier.new,
    );

/// Another seller's public shop info, keyed by their user id — used by the
/// storefront ("View Shop") screen's About tab.
final shopProfileByIdProvider = FutureProvider.family<ShopProfile, String>(
  (ref, sellerId) => ShopProfileService.fetchById(sellerId),
);
