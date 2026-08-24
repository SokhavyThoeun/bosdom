import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/wishlist_service.dart';

// Item ids are namespaced so product and co-buy ids (both plain strings)
// never collide in the shared wishlist set.
String productWishlistId(String productId) => 'product:$productId';
String coBuyWishlistId(String sessionId) => 'cobuy:$sessionId';

class WishlistNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => WishlistService.fetchWishlistIds();

  bool contains(String itemId) => state.value?.contains(itemId) ?? false;

  Future<void> toggle(String itemId) async {
    final previous = state.value ?? {};
    final optimistic = {...previous};
    if (optimistic.contains(itemId)) {
      optimistic.remove(itemId);
    } else {
      optimistic.add(itemId);
    }
    state = AsyncData(optimistic);

    try {
      final inWishlist = await WishlistService.toggleWishlist(itemId);
      final updated = {...optimistic};
      if (inWishlist) {
        updated.add(itemId);
      } else {
        updated.remove(itemId);
      }
      state = AsyncData(updated);
    } catch (_) {
      state = AsyncData(previous);
    }
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);
