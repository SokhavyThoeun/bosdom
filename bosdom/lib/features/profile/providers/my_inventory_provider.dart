import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/seller_listing.dart';
import '../services/listing_service.dart';

class MyInventoryNotifier extends AsyncNotifier<List<SellerListing>> {
  @override
  Future<List<SellerListing>> build() => ListingService.listMine();

  /// Returns whether the toggle round-tripped to the backend successfully;
  /// callers use this to surface an error when the optimistic update had
  /// to be reverted.
  Future<bool> toggleActive(SellerListing listing) async {
    final previous = state.value ?? [];
    final activated = !listing.active;
    final optimistic = [
      for (final item in previous)
        if (item.id == listing.id) item.copyWith(active: activated) else item,
    ];
    state = AsyncData(optimistic);

    try {
      final updated = await ListingService.setActive(listing.id, activated);
      state = AsyncData([
        for (final item in optimistic)
          if (item.id == updated.id) updated else item,
      ]);
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }
}

final myInventoryProvider =
    AsyncNotifierProvider<MyInventoryNotifier, List<SellerListing>>(
      MyInventoryNotifier.new,
    );
