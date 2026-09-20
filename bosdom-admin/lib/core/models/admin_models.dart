class AdminStats {
  const AdminStats({
    required this.sellerCount,
    required this.buyerCount,
    required this.listingCount,
    required this.orderCount,
    required this.pendingDisputes,
    required this.pendingKyc,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    sellerCount: json['seller_count'] as int,
    buyerCount: json['buyer_count'] as int,
    listingCount: json['listing_count'] as int,
    orderCount: json['order_count'] as int,
    pendingDisputes: json['pending_disputes'] as int,
    pendingKyc: json['pending_kyc'] as int,
  );

  final int sellerCount;
  final int buyerCount;
  final int listingCount;
  final int orderCount;
  final int pendingDisputes;
  final int pendingKyc;
}

class AdminKycDocument {
  const AdminKycDocument({required this.docType, required this.fileUrl});

  factory AdminKycDocument.fromJson(Map<String, dynamic> json) =>
      AdminKycDocument(
        docType: json['doc_type'] as String,
        fileUrl: json['file_url'] as String,
      );

  final String docType;
  final String fileUrl;
}

class AdminSeller {
  const AdminSeller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.verificationStatus,
    required this.isSuspended,
    required this.createdAt,
    required this.shopName,
    required this.shopBusinessType,
    required this.shopStoreType,
    required this.shopYearEstablished,
    required this.shopLocation,
    required this.shopPhone,
    required this.shopEmail,
    required this.shopDescription,
    required this.shopStoreUrl,
    required this.shopLogoUrl,
    required this.shopPhotoUrls,
    required this.kycDocuments,
  });

  factory AdminSeller.fromJson(Map<String, dynamic> json) => AdminSeller(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    verificationStatus: json['verification_status'] as String,
    isSuspended: json['is_suspended'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
    shopName: json['shop_name'] as String,
    shopBusinessType: json['shop_business_type'] as String,
    shopStoreType: json['shop_store_type'] as String,
    shopYearEstablished: json['shop_year_established'] as String,
    shopLocation: json['shop_location'] as String,
    shopPhone: json['shop_phone'] as String,
    shopEmail: json['shop_email'] as String,
    shopDescription: json['shop_description'] as String,
    shopStoreUrl: json['shop_store_url'] as String,
    shopLogoUrl: json['shop_logo_url'] as String,
    shopPhotoUrls: (json['shop_photo_urls'] as List).cast<String>(),
    kycDocuments: (json['kyc_documents'] as List)
        .map((e) => AdminKycDocument.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String id;
  final String name;
  final String email;
  final String phone;
  final String verificationStatus;
  final bool isSuspended;
  final DateTime createdAt;
  final String shopName;
  final String shopBusinessType;
  final String shopStoreType;
  final String shopYearEstablished;
  final String shopLocation;
  final String shopPhone;
  final String shopEmail;
  final String shopDescription;
  final String shopStoreUrl;
  final String shopLogoUrl;
  final List<String> shopPhotoUrls;
  final List<AdminKycDocument> kycDocuments;
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.verificationStatus,
    required this.isSuspended,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    role: json['role'] as String,
    verificationStatus: json['verification_status'] as String,
    isSuspended: json['is_suspended'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String verificationStatus;
  final bool isSuspended;
  final DateTime createdAt;
}

class AdminListing {
  const AdminListing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.productName,
    required this.category,
    required this.price,
    required this.stockQty,
    required this.active,
    required this.createdAt,
    required this.photoUrls,
  });

  factory AdminListing.fromJson(Map<String, dynamic> json) => AdminListing(
    id: json['id'] as String,
    sellerId: json['seller_id'] as String,
    sellerName: json['seller_name'] as String,
    productName: json['product_name'] as String,
    category: json['category'] as String,
    price: (json['price'] as num).toDouble(),
    stockQty: json['stock_qty'] as int,
    active: json['active'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
    photoUrls: (json['photo_urls'] as List<dynamic>? ?? [])
        .map((e) => e as String)
        .toList(),
  );

  final String id;
  final String sellerId;
  final String sellerName;
  final String productName;
  final String category;
  final double price;
  final int stockQty;
  final bool active;
  final DateTime createdAt;
  final List<String> photoUrls;
}

class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.productName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.shippedAt,
    this.courier,
    this.trackingNumber,
    this.deliveredAt,
    this.reviewDeadlineAt,
    this.reviewRemainingSeconds,
    this.platformFee,
    this.sellerAmount,
    this.autoReleased = false,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) => AdminOrder(
    id: json['id'] as String,
    buyerId: json['buyer_id'] as String,
    buyerName: json['buyer_name'] as String,
    sellerId: json['seller_id'] as String,
    sellerName: json['seller_name'] as String,
    productName: json['product_name'] as String,
    totalAmount: (json['total_amount'] as num).toDouble(),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    shippedAt: _date(json['shipped_at']),
    courier: json['courier'] as String?,
    trackingNumber: json['tracking_number'] as String?,
    deliveredAt: _date(json['delivered_at']),
    reviewDeadlineAt: _date(json['review_deadline_at']),
    reviewRemainingSeconds: json['review_remaining_seconds'] as int?,
    platformFee: (json['platform_fee'] as num?)?.toDouble(),
    sellerAmount: (json['seller_amount'] as num?)?.toDouble(),
    autoReleased: json['auto_released'] as bool? ?? false,
  );

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.parse(v as String);

  final String id;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String productName;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final String? courier;
  final String? trackingNumber;
  final DateTime? deliveredAt;
  final DateTime? reviewDeadlineAt;
  final int? reviewRemainingSeconds;
  final double? platformFee;
  final double? sellerAmount;
  final bool autoReleased;

  /// Where the order is in the release flow, in plain words.
  String get stageLabel {
    switch (status) {
      case 'pending_payment':
        return 'Awaiting payment';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Buyer refunded';
      case 'released':
        return autoReleased ? 'Auto-released' : 'Released to seller';
      case 'disputed':
        return 'Timer frozen';
      default:
        if (deliveredAt != null) {
          final deadline = reviewDeadlineAt;
          if (deadline == null) return 'Delivered';
          final left = deadline.difference(DateTime.now());
          if (left.isNegative) return 'Releasing…';
          return left.inHours >= 24
              ? 'Review timer · ${left.inDays}d ${left.inHours % 24}h left'
              : 'Review timer · ${left.inHours}h ${left.inMinutes % 60}m left';
        }
        return shippedAt != null ? 'Shipped' : 'Awaiting shipment';
    }
  }
}

class AdminDispute {
  const AdminDispute({
    required this.id,
    required this.orderId,
    required this.raisedBy,
    required this.reason,
    required this.note,
    required this.status,
    required this.resolution,
    required this.createdAt,
    required this.orderProductName,
    required this.orderTotalAmount,
    this.buyerName = '',
    this.sellerName = '',
    this.caseOpenedAt,
    this.sellerResponse,
    this.courierResponse,
    this.fault,
    this.courier,
    this.trackingNumber,
    this.shippingPhotoUrl,
    this.deliveryProofUrl,
    this.frozenSecondsLeft,
    this.evidenceUrls = const [],
    this.sellerPayout = 0,
    this.platformFee = 0,
  });

  factory AdminDispute.fromJson(Map<String, dynamic> json) => AdminDispute(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    raisedBy: json['raised_by'] as String,
    reason: json['reason'] as String,
    note: json['note'] as String,
    status: json['status'] as String,
    resolution: json['resolution'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    orderProductName: json['order_product_name'] as String,
    orderTotalAmount: (json['order_total_amount'] as num).toDouble(),
    buyerName: json['buyer_name'] as String? ?? '',
    sellerName: json['seller_name'] as String? ?? '',
    caseOpenedAt: json['case_opened_at'] == null
        ? null
        : DateTime.parse(json['case_opened_at'] as String),
    sellerResponse: json['seller_response'] as String?,
    courierResponse: json['courier_response'] as String?,
    fault: json['fault'] as String?,
    courier: json['courier'] as String?,
    trackingNumber: json['tracking_number'] as String?,
    shippingPhotoUrl: json['shipping_photo_url'] as String?,
    deliveryProofUrl: json['delivery_proof_url'] as String?,
    frozenSecondsLeft: json['frozen_seconds_left'] as int?,
    evidenceUrls: (json['evidence_urls'] as List? ?? const []).cast<String>(),
    sellerPayout: (json['seller_payout'] as num? ?? 0).toDouble(),
    platformFee: (json['platform_fee'] as num? ?? 0).toDouble(),
  );

  final String id;
  final String orderId;
  final String raisedBy;
  final String reason;
  final String note;
  final String status;
  final String? resolution;
  final DateTime createdAt;
  final String orderProductName;
  final double orderTotalAmount;
  final String buyerName;
  final String sellerName;
  final DateTime? caseOpenedAt;
  final String? sellerResponse;
  final String? courierResponse;
  final String? fault;
  final String? courier;
  final String? trackingNumber;
  final String? shippingPhotoUrl;
  final String? deliveryProofUrl;
  final int? frozenSecondsLeft;
  final List<String> evidenceUrls;

  /// What the seller gets (order total minus fee) if funds are released.
  final double sellerPayout;
  final double platformFee;

  bool get isResolved => status == 'resolved';
  bool get isCaseOpen => status == 'case_open';
}

class AdminPayoutRequest {
  const AdminPayoutRequest({
    required this.orderId,
    required this.sellerName,
    required this.buyerName,
    required this.productName,
    required this.totalAmount,
    required this.payoutAmount,
    required this.status,
    required this.requestedAt,
    required this.releasedAt,
    this.bankName,
    this.accountHolder,
    this.accountNumber,
  });

  factory AdminPayoutRequest.fromJson(Map<String, dynamic> json) =>
      AdminPayoutRequest(
        orderId: json['order_id'] as String,
        sellerName: json['seller_name'] as String,
        buyerName: json['buyer_name'] as String,
        productName: json['product_name'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        payoutAmount: (json['payout_amount'] as num).toDouble(),
        status: json['status'] as String,
        requestedAt: DateTime.parse(json['requested_at'] as String),
        releasedAt: json['released_at'] == null
            ? null
            : DateTime.parse(json['released_at'] as String),
        bankName: json['bank_name'] as String?,
        accountHolder: json['account_holder'] as String?,
        accountNumber: json['account_number'] as String?,
      );

  final String orderId;
  final String sellerName;
  final String buyerName;
  final String productName;
  final double totalAmount;
  final String? bankName;
  final String? accountHolder;
  final String? accountNumber;

  /// What the seller receives — [totalAmount] minus the platform fee.
  final double payoutAmount;
  final String status;
  final DateTime requestedAt;
  final DateTime? releasedAt;

  /// `pending` until the admin approves the seller's withdrawal.
  bool get isApproved => status == 'approved';
}

class AdminSupportConversation {
  const AdminSupportConversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.unreadCount,
    required this.lastMessagePreview,
    required this.lastMessageAt,
  });

  factory AdminSupportConversation.fromJson(Map<String, dynamic> json) =>
      AdminSupportConversation(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userEmail: json['user_email'] as String,
        userRole: json['user_role'] as String,
        unreadCount: json['unread_count'] as int,
        lastMessagePreview: json['last_message_preview'] as String,
        lastMessageAt: json['last_message_at'] == null
            ? null
            : DateTime.parse(json['last_message_at'] as String),
      );

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userRole;
  final int unreadCount;
  final String lastMessagePreview;
  final DateTime? lastMessageAt;
}

class AdminSupportMessage {
  const AdminSupportMessage({
    required this.id,
    required this.fromSupport,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
  });

  factory AdminSupportMessage.fromJson(Map<String, dynamic> json) =>
      AdminSupportMessage(
        id: json['id'] as String,
        fromSupport: json['sender_id'] == 'bosdom-support',
        text: json['text'] as String?,
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final bool fromSupport;
  final String? text;
  final String? imageUrl;
  final DateTime createdAt;
}

class AdminSellerReport {
  const AdminSellerReport({
    required this.id,
    required this.orderId,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.productName,
    required this.reason,
    required this.note,
    required this.photoUrls,
    required this.status,
    required this.orderStatus,
    required this.refundDueAt,
    required this.resolution,
    required this.createdAt,
  });

  factory AdminSellerReport.fromJson(Map<String, dynamic> json) =>
      AdminSellerReport(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        sellerId: json['seller_id'] as String,
        sellerName: json['seller_name'] as String,
        buyerId: json['buyer_id'] as String,
        buyerName: json['buyer_name'] as String,
        productName: json['product_name'] as String,
        reason: json['reason'] as String,
        note: json['note'] as String,
        photoUrls: (json['photo_urls'] as List).cast<String>(),
        status: json['status'] as String,
        orderStatus: (json['order_status'] as String?) ?? '',
        refundDueAt: json['refund_due_at'] == null
            ? null
            : DateTime.parse(json['refund_due_at'] as String),
        resolution: json['resolution'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String orderId;
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;
  final String productName;
  final String reason;
  final String note;
  final List<String> photoUrls;
  final String status;
  final String orderStatus;
  final DateTime? refundDueAt;
  final String? resolution;
  final DateTime createdAt;

  bool get isResolved => status == 'resolved';
  bool get isRefundPending => status == 'refund_pending';

  /// Money can't be returned once the order is already paid out, refunded or
  /// cancelled (the backend enforces this too).
  bool get canRefund =>
      !isResolved &&
      orderStatus != 'released' &&
      orderStatus != 'refunded' &&
      orderStatus != 'cancelled';

  String get reasonLabel => switch (reason) {
    'delivery_delayed' => 'Delivery delayed',
    'parcel_lost_or_damaged' => 'Parcel lost or damaged',
    'buyer_unreachable' => 'Buyer unreachable',
    'address_problem' => 'Address problem',
    _ => 'Other',
  };
}

class AdminCoBuyLeave {
  const AdminCoBuyLeave({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.buyerName,
    required this.quantity,
    required this.amount,
    required this.reason,
    required this.requestedAt,
    required this.decision,
    this.paymentMethod,
    this.adminNote,
  });

  factory AdminCoBuyLeave.fromJson(Map<String, dynamic> json) =>
      AdminCoBuyLeave(
        id: json['id'] as String,
        productName: json['product_name'] as String,
        sellerName: json['seller_name'] as String,
        buyerName: json['buyer_name'] as String,
        quantity: json['quantity'] as int,
        amount: (json['amount'] as num).toDouble(),
        paymentMethod: json['payment_method'] as String?,
        reason: json['reason'] as String,
        requestedAt: DateTime.parse(json['requested_at'] as String),
        decision: json['decision'] as String,
        adminNote: json['admin_note'] as String?,
      );

  final String id;
  final String productName;
  final String sellerName;
  final String buyerName;
  final int quantity;
  final double amount;
  final String? paymentMethod;
  final String reason;
  final DateTime requestedAt;

  /// `pending`, `approved` (refunded) or `rejected`.
  final String decision;
  final String? adminNote;

  bool get isPending => decision == 'pending';
}
