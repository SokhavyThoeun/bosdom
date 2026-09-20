import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../marketplace/models/product.dart';
import '../../marketplace/services/listings_service.dart';
import '../services/cart_service.dart';

class CartLine {
  CartLine({required this.product, required this.quantity}) : selected = true;

  final Product product;
  int quantity;
  bool selected;

  double get unitPrice => product.priceValue;
  double get lineTotal => unitPrice * quantity;
}

class CartGroup {
  CartGroup({required this.seller, required this.lines});

  final String seller;
  final List<CartLine> lines;

  bool get allSelected => lines.every((line) => line.selected);

  /// The seller's real shop logo when available, else a generated mock logo.
  String get sellerLogoUrl => lines.first.product.sellerLogoUrl;
}

class CartNotifier extends AsyncNotifier<List<CartLine>> {
  @override
  Future<List<CartLine>> build() async {
    final quantities = await CartService.fetchCart();
    final lines = await Future.wait(
      quantities.entries.map((entry) async {
        try {
          final product = await ListingsService.resolveProduct(entry.key);
          return CartLine(product: product, quantity: entry.value);
        } catch (_) {
          // The listing behind this cart line may have been deleted since
          // it was added; drop it rather than failing the whole cart.
          return null;
        }
      }),
    );
    return lines.whereType<CartLine>().toList();
  }

  List<CartLine> get _lines => state.value ?? const [];

  List<CartGroup> get groups {
    final groups = <String, CartGroup>{};
    for (final line in _lines) {
      groups
          .putIfAbsent(
            line.product.seller,
            () => CartGroup(seller: line.product.seller, lines: []),
          )
          .lines
          .add(line);
    }
    return groups.values.toList();
  }

  /// Returns whether the add round-tripped to the backend successfully;
  /// callers use this to surface an error when the optimistic update had
  /// to be reverted.
  Future<bool> addItems(List<(Product product, int quantity)> items) async {
    final previous = _lines;
    final optimistic = [...previous];
    for (final (product, quantity) in items) {
      final index = optimistic.indexWhere(
        (line) => line.product.id == product.id,
      );
      if (index != -1) {
        optimistic[index].quantity += quantity;
      } else {
        optimistic.add(CartLine(product: product, quantity: quantity));
      }
    }
    state = AsyncData(optimistic);

    try {
      for (final (product, quantity) in items) {
        await CartService.addItem(product.id, quantity);
      }
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }

  void toggleAll(bool? value) {
    for (final line in _lines) {
      line.selected = value ?? false;
    }
    state = AsyncData([..._lines]);
  }

  void toggleGroup(CartGroup group, bool? value) {
    for (final line in group.lines) {
      line.selected = value ?? false;
    }
    state = AsyncData([..._lines]);
  }

  void toggleLine(CartLine line, bool? value) {
    line.selected = value ?? false;
    state = AsyncData([..._lines]);
  }

  Future<bool> changeQuantity(CartLine line, int delta) async {
    final previousQuantity = line.quantity;
    final nextQuantity = (previousQuantity + delta).clamp(
      line.product.moqValue,
      9999,
    );
    if (nextQuantity == previousQuantity) return true;

    line.quantity = nextQuantity;
    state = AsyncData([..._lines]);

    try {
      await CartService.updateQuantity(line.product.id, nextQuantity);
      return true;
    } catch (_) {
      line.quantity = previousQuantity;
      state = AsyncData([..._lines]);
      return false;
    }
  }

  Future<bool> removeLine(CartLine line) async {
    final previous = _lines;
    state = AsyncData(previous.where((l) => l != line).toList());

    try {
      await CartService.removeItem(line.product.id);
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }

  /// Drops cart lines for products just checked out and paid for (matched
  /// by real backend listing id) — mock/co-buy lines have no listing id to
  /// match, so they're untouched.
  Future<void> removeByListingIds(Set<String> listingIds) async {
    if (listingIds.isEmpty) return;
    state = AsyncData(
      _lines.where((line) => !listingIds.contains(line.product.id)).toList(),
    );
    try {
      await CartService.removeItems(listingIds);
    } catch (_) {
      // Best-effort cleanup: the items were just paid for, so leaving them
      // behind on the backend cart (to be pruned on next full sync) is
      // preferable to blocking the post-payment flow on this call.
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartLine>>(
  CartNotifier.new,
);
