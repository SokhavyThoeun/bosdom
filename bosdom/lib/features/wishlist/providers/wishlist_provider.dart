import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../marketplace/models/product.dart';
import '../../marketplace/services/listings_service.dart';
import '../services/wishlist_service.dart';

// Item ids are namespaced so product and co-buy ids (both plain strings)
// never collide in the shared wishlist set.
String productWishlistId(String productId) => 'product:$productId';
String coBuyWishlistId(String sessionId) => 'cobuy:$sessionId';

const _kProductWishlistPrefix = 'product:';

class WishlistNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => WishlistService.fetchWishlistIds();

  bool contains(String itemId) => state.value?.contains(itemId) ?? false;

  /// Returns whether the toggle round-tripped to the backend successfully;
  /// callers use this to surface an error when the optimistic update had
  /// to be reverted.
  Future<bool> toggle(String itemId) async {
    final previous = state.value ?? {};
    final optimistic = {...previous};
    final willBeInWishlist = !optimistic.contains(itemId);
    if (willBeInWishlist) {
      optimistic.add(itemId);
    } else {
      optimistic.remove(itemId);
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
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

/// The full [Product] for every product wishlisted (co-buy wishlist entries
/// aren't products and are excluded), for the Wishlist screen to render.
final wishlistProductsProvider = FutureProvider.autoDispose<List<Product>>((
  ref,
) async {
  final ids = await ref.watch(wishlistProvider.future);
  final productIds = [
    for (final id in ids)
      if (id.startsWith(_kProductWishlistPrefix))
        id.substring(_kProductWishlistPrefix.length),
  ];

  final products = await Future.wait(
    productIds.map((id) async {
      try {
        return await ListingsService.resolveProduct(id);
      } catch (_) {
        // The listing behind this wishlist entry may have been deleted
        // since it was added; drop it rather than failing the whole list.
        return null;
      }
    }),
  );
  return products.whereType<Product>().toList();
});
