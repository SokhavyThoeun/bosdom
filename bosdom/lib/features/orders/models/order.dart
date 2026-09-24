import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/api_config.dart';
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
}

/// Buyer-facing wording for the escrow [OrderStatus] — the escrow/payment
/// ledger terms ("held", "released") belong to the seller's earnings screen,
/// so a buyer sees fulfillment progress instead: has the seller started
/// working on the order yet, mirroring [Order.isSellerConfirmed].
String buyerOrderStatusLabel(
  OrderStatus status, {
  bool isSellerConfirmed = true,
}) => switch (status) {
  OrderStatus.pendingPayment => 'Awaiting Payment',
  OrderStatus.held => isSellerConfirmed ? 'Delivery' : 'Order Placed',
  OrderStatus.released => 'Completed',
  OrderStatus.disputed => 'Disputed',
  OrderStatus.refunded => 'Refunded',
  OrderStatus.cancelled => 'Cancelled',
};

/// The buyer's star rating + written review (+ optional photos) of a
/// completed order, matching `OrderReviewOut` (`routers/orders.py`).
/// Embedded on [Order.review] rather than fetched separately, so both the
/// buyer's and the seller's order detail screens get it for free.
class OrderReview {
  const OrderReview({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.rating,
    required this.comment,
    required this.photoUrls,
    required this.createdAt,
    this.buyerName,
    this.buyerAvatarUrl,
  });

  factory OrderReview.fromJson(Map<String, dynamic> json) => OrderReview(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    buyerId: json['buyer_id'] as String,
    rating: json['rating'] as int,
    comment: json['comment'] as String,
    photoUrls: (json['photo_urls'] as List)
        .cast<String>()
        .map((url) => ApiConfig.resolveAvatarUrl(url)!)
        .toList(),
    createdAt: DateTime.parse(json['created_at'] as String),
    buyerName: json['buyer_name'] as String?,
    buyerAvatarUrl: ApiConfig.resolveAvatarUrl(
      json['buyer_avatar_url'] as String?,
    ),
  );

  final String id;
  final String orderId;
  final String buyerId;
  final int rating;
  final String comment;
  final List<String> photoUrls;
  final DateTime createdAt;
  final String? buyerName;
  final String? buyerAvatarUrl;

  String get dateLabel => DateFormat.yMMMd().format(createdAt.toLocal());
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
    this.sellerConfirmedAt,
    this.releasedAt,
    this.platformFee,
    this.releaseRequestedAt,
    this.cancelledAt,
    this.refundedAt,
    this.payoutRequestedAt,
    this.payoutEtaAt,
    this.shippedAt,
    this.courier,
    this.trackingNumber,
    this.shippingPhotoUrl,
    this.deliveredAt,
    this.deliveryProofUrl,
    this.reviewDeadlineAt,
    this.reviewRemainingSeconds,
    this.autoReleased = false,
    this.imageUrl,
    this.sellerName,
    this.sellerLogoUrlOverride,
    this.review,
    this.holdSource,
    this.holdReason,
    this.holdNote,
    this.refundDueAt,
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
    sellerConfirmedAt: _parseNullable(json['seller_confirmed_at']),
    releasedAt: _parseNullable(json['released_at']),
    platformFee: (json['platform_fee'] as num?)?.toDouble(),
    releaseRequestedAt: _parseNullable(json['release_requested_at']),
    cancelledAt: _parseNullable(json['cancelled_at']),
    refundedAt: _parseNullable(json['refunded_at']),
    payoutRequestedAt: _parseNullable(json['payout_requested_at']),
    payoutEtaAt: _parseNullable(json['payout_eta_at']),
    shippedAt: _parseNullable(json['shipped_at']),
    courier: json['courier'] as String?,
    trackingNumber: json['tracking_number'] as String?,
    shippingPhotoUrl: ApiConfig.resolveAvatarUrl(
      json['shipping_photo_url'] as String?,
    ),
    deliveredAt: _parseNullable(json['delivered_at']),
    deliveryProofUrl: ApiConfig.resolveAvatarUrl(
      json['delivery_proof_url'] as String?,
    ),
    reviewDeadlineAt: _parseNullable(json['review_deadline_at']),
    reviewRemainingSeconds: json['review_remaining_seconds'] as int?,
    autoReleased: json['auto_released'] as bool? ?? false,
    imageUrl: ApiConfig.resolveAvatarUrl(json['image_url'] as String?),
    sellerName: json['seller_name'] as String?,
    sellerLogoUrlOverride: ApiConfig.resolveAvatarUrl(
      json['seller_logo_url'] as String?,
    ),
    holdSource: json['hold_source'] as String?,
    holdReason: json['hold_reason'] as String?,
    holdNote: json['hold_note'] as String?,
    refundDueAt: _parseNullable(json['refund_due_at']),
    review: json['review'] == null
        ? null
        : OrderReview.fromJson(json['review'] as Map<String, dynamic>),
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
  final DateTime? sellerConfirmedAt;
  final DateTime? releasedAt;

  /// The commission actually taken at release; `null` until then.
  final double? platformFee;
  final DateTime? releaseRequestedAt;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;

  /// Set once the seller has withdrawn this released order's earnings to a
  /// bank account; the money lands at [payoutEtaAt].
  final DateTime? payoutRequestedAt;
  final DateTime? payoutEtaAt;

  /// Fulfilment proof: the seller's parcel photo + tracking, then proof of
  /// delivery, which starts the buyer's [reviewDeadlineAt] timer.
  final DateTime? shippedAt;
  final String? courier;
  final String? trackingNumber;
  final String? shippingPhotoUrl;
  final DateTime? deliveredAt;
  final String? deliveryProofUrl;

  /// When the review timer ends and funds auto-release. `null` while frozen
  /// by a reported problem ([reviewRemainingSeconds] holds the time left).
  final DateTime? reviewDeadlineAt;
  final int? reviewRemainingSeconds;
  final bool autoReleased;
  final String? imageUrl;
  final String? sellerName;

  /// Real shop logo URL for the order's seller, when the backend resolved
  /// one. `null` when the seller has no shop logo uploaded.
  final String? sellerLogoUrlOverride;

  /// The buyer's rating/review of this order, once they've left one.
  final OrderReview? review;

  /// Why a disputed order is on hold: `buyer` (they reported a problem) or
  /// `delivery` (an admin cancelled it over a courier problem).
  final String? holdSource;
  final String? holdReason;
  final String? holdNote;

  /// When the buyer's refund goes out, once an admin has scheduled it.
  final DateTime? refundDueAt;

  /// The seller's real shop logo when available, else a generated mock logo
  /// keyed off [sellerName] (matches [Product.sellerLogoUrl]'s fallback).
  String? get sellerLogoUrl =>
      sellerLogoUrlOverride ??
      (sellerName == null ? null : mockStoreLogoUrl(sellerName!));

  String get dateLabel => DateFormat.yMMMd().format(createdAt.toLocal());

  /// Short human-facing order number (e.g. `BD-98517`), derived from the
  /// backend's UUID `id` so it stays unique without showing the raw UUID.
  String get displayNumber {
    final digits = id
        .replaceFirst('cobuy-', '')
        .replaceAll(RegExp('[^0-9A-Za-z]'), '');
    final shortCode = digits.length >= 5
        ? digits.substring(0, 5)
        : digits.padLeft(5, '0');
    return 'BD-${shortCode.toUpperCase()}';
  }

  /// Fallback when the listing has no photo (or was removed) — the same
  /// generic wholesale-box art used elsewhere for unmatched mock items.
  IconData get icon => Icons.inventory_2_outlined;

  bool get isSellerConfirmed => sellerConfirmedAt != null;

  bool get isShipped => shippedAt != null;
  bool get isDelivered => deliveredAt != null;

  /// Held funds, parcel on its way or delivered: the buyer can still report
  /// a problem (until the review timer ends).
  bool get canReportProblem => status == OrderStatus.held && isShipped;

  bool get isActive =>
      status == OrderStatus.pendingPayment ||
      status == OrderStatus.held ||
      status == OrderStatus.disputed;
}
