import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop_profile.dart';
import '../services/shop_profile_service.dart';

class ShopProfileNotifier extends AsyncNotifier<ShopProfile> {
  @override
  Future<ShopProfile> build() => ShopProfileService.fetch();

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
}

final shopProfileProvider =
    AsyncNotifierProvider<ShopProfileNotifier, ShopProfile>(
      ShopProfileNotifier.new,
    );
