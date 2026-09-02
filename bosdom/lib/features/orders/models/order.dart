import 'package:flutter/material.dart';

import '../../marketplace/models/product.dart';

enum OrderStatus {
  processing,
  shipped,
  delivered,
  cancelled;

  String get label => switch (this) {
    OrderStatus.processing => 'Processing',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };
}

// Historical order pricing can differ from the live catalog (bulk deals,
// past promotions), so a couple of order-only product records live here
// instead of pointing at `kMockProducts`.
const _kJasmineRiceHistorical = Product(
  name: 'Premium Jasmine Rice (25kg Bag)',
  price: '\$45.00',
  moq: 'MOQ: 20 Bags',
  moqValue: 20,
  seller: 'Mekong Agri-Food Co.',
  icon: Icons.rice_bowl_outlined,
  category: 'Food & Bev',
  imageQuery: 'jasmine,rice,bag',
);

const _kCashewNutsHistorical = Product(
  name: 'Roasted Cashew Nuts (5kg Bag)',
  price: '\$69.17',
  moq: 'MOQ: 12 Bags',
  moqValue: 12,
  seller: 'Angkor BioSource',
  icon: Icons.eco_outlined,
  category: 'Food & Bev',
  imageQuery: 'roasted,cashew,nuts',
);

Product _productNamed(String name) =>
    kMockProducts.firstWhere((product) => product.name == name);

class OrderLineItem {
  const OrderLineItem({
    required this.product,
    required this.quantity,
    required this.unitLabel,
  });

  final Product product;
  final int quantity;

  /// Unit noun shown next to the quantity, e.g. "Bags" or "Cases".
  final String unitLabel;

  double get lineTotal => product.priceValue * quantity;

  String get qtyLabel => 'Qty: $quantity $unitLabel × ${product.price}';
}

class Order {
  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.shippingName,
    required this.shippingAddress,
    required this.shippingPhone,
    this.discount = 0,
    this.shippingFee = 0,
    this.deliveryMethod = 'Standard Delivery',
  });

  final String id;
  final String date;
  final OrderStatus status;
  final List<OrderLineItem> items;
  final String shippingName;
  final String shippingAddress;
  final String shippingPhone;
  final double discount;
  final double shippingFee;
  final String deliveryMethod;

  IconData get icon => items.first.product.icon;

  String get productName => items.length > 1
      ? '${items.first.product.name} +${items.length - 1} more'
      : items.first.product.name;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.lineTotal);

  double get total => subtotal - discount + shippingFee;

  String get shippingFeeLabel =>
      shippingFee == 0 ? 'Free' : '\$${shippingFee.toStringAsFixed(2)}';
}

final kMockOrders = [
  Order(
    id: 'BD-98402',
    date: 'Oct 28, 2025',
    status: OrderStatus.delivered,
    items: [
      OrderLineItem(
        product: _kJasmineRiceHistorical,
        quantity: 20,
        unitLabel: 'Bags',
      ),
      OrderLineItem(
        product: _productNamed('Thai Premium Fish Sauce (Case of 12)'),
        quantity: 10,
        unitLabel: 'Cases',
      ),
      OrderLineItem(
        product: _productNamed('Organic Coconut Milk (Case of 24)'),
        quantity: 4,
        unitLabel: 'Cases',
      ),
    ],
    shippingName: 'Angkor Wholesale Distribution',
    shippingAddress:
        'Building 42B, Russian Federation Blvd, Sangkat Toeuk Thla, '
        'Khan Sen Sok, Phnom Penh, 120801, Cambodia',
    shippingPhone: '+855 12 345 678',
    discount: 30.40,
    deliveryMethod: 'Vireak Buntham Express',
  ),
  Order(
    id: 'BD-98211',
    date: 'Oct 15, 2025',
    status: OrderStatus.shipped,
    items: [
      OrderLineItem(
        product: kMockProducts[0],
        quantity: 48,
        unitLabel: 'Bags',
      ),
    ],
    shippingName: 'Riverside Trading Co.',
    shippingAddress:
        'Street 271, Sangkat Boeung Tumpun, Khan Mean Chey, Phnom Penh, '
        'Cambodia',
    shippingPhone: '+855 92 456 789',
    deliveryMethod: 'J&T Express',
  ),
  Order(
    id: 'BD-97992',
    date: 'Sep 30, 2025',
    status: OrderStatus.delivered,
    items: [
      OrderLineItem(
        product: _kCashewNutsHistorical,
        quantity: 12,
        unitLabel: 'Bags',
      ),
    ],
    shippingName: 'Battambang Fresh Market',
    shippingAddress:
        'National Road 5, Sangkat Svay Por, Battambang, Cambodia',
    shippingPhone: '+855 77 654 321',
    shippingFee: 8.00,
    deliveryMethod: 'Grab Express',
  ),
  Order(
    id: 'BD-97814',
    date: 'Sep 12, 2025',
    status: OrderStatus.cancelled,
    items: [
      OrderLineItem(
        product: _productNamed('Dried Organic Mango Slices (1kg)'),
        quantity: 27,
        unitLabel: 'Bags',
      ),
    ],
    shippingName: 'Siem Reap Snacks Ltd.',
    shippingAddress: 'Wat Bo Road, Sangkat Sala Kamreuk, Siem Reap, Cambodia',
    shippingPhone: '+855 88 112 233',
    shippingFee: 5.00,
  ),
];
