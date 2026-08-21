import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../marketplace/models/product.dart';

class CartLine {
  CartLine({required this.product, required this.quantity})
    : selected = true;

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
}

class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => [
    CartLine(product: kMockProducts[0], quantity: 20),
    CartLine(
      product: kMockProducts.firstWhere(
        (p) => p.name.startsWith('Biodegradable'),
      ),
      quantity: 5,
    ),
    CartLine(product: kMockProducts[2], quantity: 100),
  ];

  List<CartGroup> get groups {
    final groups = <String, CartGroup>{};
    for (final line in state) {
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

  void addItems(List<(Product product, int quantity)> items) {
    final next = [...state];
    for (final (product, quantity) in items) {
      final index = next.indexWhere(
        (line) => line.product.name == product.name,
      );
      if (index != -1) {
        next[index].quantity += quantity;
      } else {
        next.add(CartLine(product: product, quantity: quantity));
      }
    }
    state = next;
  }

  void toggleAll(bool? value) {
    for (final line in state) {
      line.selected = value ?? false;
    }
    state = [...state];
  }

  void toggleGroup(CartGroup group, bool? value) {
    for (final line in group.lines) {
      line.selected = value ?? false;
    }
    state = [...state];
  }

  void toggleLine(CartLine line, bool? value) {
    line.selected = value ?? false;
    state = [...state];
  }

  void changeQuantity(CartLine line, int delta) {
    line.quantity = (line.quantity + delta).clamp(1, 9999);
    state = [...state];
  }

  void removeLine(CartLine line) {
    state = state.where((l) => l != line).toList();
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(
  CartNotifier.new,
);
