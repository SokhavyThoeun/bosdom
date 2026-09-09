class SampleOrder {
  const SampleOrder({
    required this.id,
    required this.listingId,
    required this.sellerId,
    required this.productName,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String sellerId;
  final String productName;
  final double price;
  final String status;
  final DateTime createdAt;

  factory SampleOrder.fromJson(Map<String, dynamic> json) => SampleOrder(
    id: json['id'] as String,
    listingId: json['listing_id'] as String,
    sellerId: json['seller_id'] as String,
    productName: json['product_name'] as String,
    price: (json['price'] as num).toDouble(),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class SampleEligibility {
  const SampleEligibility({
    required this.eligible,
    required this.eligibleAt,
    required this.lastSampleOrder,
  });

  final bool eligible;
  final DateTime? eligibleAt;
  final SampleOrder? lastSampleOrder;

  factory SampleEligibility.fromJson(Map<String, dynamic> json) =>
      SampleEligibility(
        eligible: json['eligible'] as bool,
        eligibleAt: json['eligible_at'] != null
            ? DateTime.parse(json['eligible_at'] as String)
            : null,
        lastSampleOrder: json['last_sample_order'] != null
            ? SampleOrder.fromJson(
                json['last_sample_order'] as Map<String, dynamic>,
              )
            : null,
      );
}

/// Thrown by [SampleOrderService.requestSample] when the buyer is still
/// inside the backend's 3-day cooldown window (HTTP 409).
class SampleCooldownException implements Exception {
  const SampleCooldownException(this.message, this.eligibleAt);

  final String message;
  final DateTime? eligibleAt;
}

/// Thrown for any other failed sample-order request (listing not found,
/// listing doesn't offer sampling, network/server error).
class SampleOrderException implements Exception {
  const SampleOrderException(this.message);

  final String message;
}
