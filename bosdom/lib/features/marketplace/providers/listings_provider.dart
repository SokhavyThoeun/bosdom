import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/listings_service.dart';

/// All buyer-facing listings from the backend, used by the marketplace grid,
/// search, category results, and store profile screens.
final listingsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  return ListingsService.fetchListings();
});

/// A single listing by id, for the product detail screen.
final listingByIdProvider = FutureProvider.autoDispose.family<Product, String>((
  ref,
  id,
) {
  return ListingsService.resolveProduct(id);
});
