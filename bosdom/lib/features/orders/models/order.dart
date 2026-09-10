import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/utils/mock_images.dart';

/// Mirrors the backend's escrow status state machine exactly
/// (`bosdom-backend/routers/orders.py`) — there is no separate delivery
/// timeline (packed/shipped/out-for-delivery) tracked server-side, only
/// these escrow states.
enum OrderStatus {
  pendingPayment,
  held,
  released,
  disputed,
  refunded,
  cancelled;

  static OrderStatus fromApiValue(String value) => switch (value) {
    'pending_payment' => OrderStatus.pendingPayment,
    'held' => OrderStatus.held,
    'released' => OrderStatus.released,
    'disputed' => OrderStatus.disputed,
    'refunded' => OrderStatus.refunded,
    'cancelled' => OrderStatus.cancelled,
    _ => OrderStatus.pendingPayment,
  };

  String get label => switch (this) {
    OrderStatus.pendingPayment => 'Awaiting Payment',
    OrderStatus.held => 'Payment Held (Escrow)',
    OrderStatus.released => 'Released',
    OrderStatus.disputed => 'Disputed',
    OrderStatus.refunded => 'Refunded',
    OrderStatus.cancelled => 'Cancelled',
  };
}

/// A buyer's real order, matching `OrderOut` (`routers/orders.py`) — one
/// listing per order, snapshotted product/price at purchase time, tracked
/// through an escrow status rather than a delivery-carrier timeline.
class Order {
  const Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.listingId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    required this.shippingName,
    required this.shippingAddress,
    required this.shippingPhone,
    required this.status,
    required this.createdAt,
    this.paymentMethod,
    this.paidAt,
    this.releasedAt,
    this.cancelledAt,
    this.refundedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    buyerId: json['buyer_id'] as String,
    sellerId: json['seller_id'] as String,
    listingId: json['listing_id'] as String,
    productName: json['product_name'] as String,
    unitPrice: (json['unit_price'] as num).toDouble(),
    quantity: json['quantity'] as int,
    totalAmount: (json['total_amount'] as num).toDouble(),
    shippingName: json['shipping_name'] as String,
    shippingAddress: json['shipping_address'] as String,
    shippingPhone: json['shipping_phone'] as String,
    status: OrderStatus.fromApiValue(json['status'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    paymentMethod: json['payment_method'] as String?,
    paidAt: _parseNullable(json['paid_at']),
    releasedAt: _parseNullable(json['released_at']),
    cancelledAt: _parseNullable(json['cancelled_at']),
    refundedAt: _parseNullable(json['refunded_at']),
  );

  static DateTime? _parseNullable(Object? value) =>
      value == null ? null : DateTime.parse(value as String);

  final String id;
  final String buyerId;
  final String sellerId;
  final String listingId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalAmount;
  final String shippingName;
  final String shippingAddress;
  final String shippingPhone;
  final OrderStatus status;
  final DateTime createdAt;
  final String? paymentMethod;
  final DateTime? paidAt;
  final DateTime? releasedAt;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;

  String get dateLabel => DateFormat.yMMMd().format(createdAt.toLocal());

  /// No product icon/photo comes back from the backend, so every real order
  /// falls back to the same generic wholesale-box art used elsewhere for
  /// unmatched mock items.
  IconData get icon => Icons.inventory_2_outlined;

  String get imageUrl => mockPhotoUrl('wholesale,shipping,box', productName);

  bool get isActive =>
      status == OrderStatus.pendingPayment ||
      status == OrderStatus.held ||
      status == OrderStatus.disputed;
}
