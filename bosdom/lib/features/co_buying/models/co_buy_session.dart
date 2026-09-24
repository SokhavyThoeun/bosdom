import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../shared/models/variant_option.dart';
import '../../../shared/utils/mock_images.dart';

enum CoBuyDealStatus { active, completed, expired }

class CoBuySession {
  const CoBuySession({
    required this.id,
    required this.icon,
    required this.imageQuery,
    required this.productName,
    required this.sellerName,
    required this.sellerLocation,
    required this.sellerVerified,
    required this.currentQty,
    required this.targetQty,
    required this.unitLabel,
    required this.perUnitLabel,
    required this.minOrderQty,
    required this.retailersJoined,
    required this.timeLeft,
    required this.originalPrice,
    required this.price,
    required this.joined,
    this.sellerRating = 4.8,
    this.category = '',
    this.description = '',
    this.autoRenew = false,
    this.myStatus,
    this.myLeaveAdminNote,
    this.sellerLogoOverride,
    this.photoUrls = const [],
    this.sizes = const [],
    this.colorOptions = const [],
    this.weight = '',
    this.origin = '',
    this.grade = '',
    this.packaging = '',
  });

  final String id;
  final IconData icon;

  /// Keyword(s) used to fetch a topic-matched mock product photo when no
  /// real photo has been uploaded.
  final String imageQuery;
  final String productName;
  final String category;
  final String description;
  final String weight;
  final String origin;
  final String grade;
  final String packaging;
  final String sellerName;
  final double sellerRating;
  final String sellerLocation;
  final bool sellerVerified;
  final int currentQty;
  final int targetQty;
  final String unitLabel;
  final String perUnitLabel;
  final int minOrderQty;
  final int retailersJoined;
  final String timeLeft;
  final double originalPrice;
  final double price;
  final bool joined;
  final bool autoRenew;

  /// Real network logo for the seller's shop, when one exists.
  final String? sellerLogoOverride;

  /// Real seller-uploaded product photos (first is the cover). Falls back to
  /// [imageUrl]'s curated mock photo when empty.
  final List<String> photoUrls;

  /// Selectable sizes (e.g. clothing). Empty when the session has no size
  /// variants.
  final List<String> sizes;

  /// Selectable colors. Empty when the session has no color variants.
  final List<ProductColorOption> colorOptions;

  /// The viewer's own escrow state on this deal (`held`, `leave_requested`,
  /// `released`), or null when they haven't paid in.
  final String? myStatus;

  /// The admin's reason when the viewer's last leave request was rejected.
  final String? myLeaveAdminNote;

  bool get leavePending => myStatus == 'leave_requested';

  bool get hasVariants => sizes.isNotEmpty || colorOptions.isNotEmpty;

  double get progress => currentQty / targetQty;
  int get remainingQty => targetQty - currentQty;
  bool get isFull => currentQty >= targetQty;
  int get savingsPct =>
      (((originalPrice - price) / originalPrice) * 100).round();

  /// A deal that ran out of time without reaching its target is tagged by
  /// putting "expired" in [timeLeft] — there's no separate deadline clock in
  /// this data model.
  CoBuyDealStatus get dealStatus {
    if (timeLeft.toLowerCase().contains('expired')) {
      return CoBuyDealStatus.expired;
    }
    if (isFull) return CoBuyDealStatus.completed;
    return CoBuyDealStatus.active;
  }

  /// The real seller-uploaded cover photo, or a topic-matched mock photo.
  String get imageUrl =>
      photoUrls.isNotEmpty ? photoUrls.first : mockPhotoUrl(imageQuery, id);

  /// Real shop logo when set, otherwise a clean mock logo for the seller.
  String get sellerLogoUrl =>
      sellerLogoOverride ?? mockStoreLogoUrl(sellerName);

  factory CoBuySession.fromJson(Map<String, dynamic> json) {
    final productName = json['product_name'] as String;
    final photoUrls = (json['photo_urls'] as List)
        .cast<String>()
        .map((url) => ApiConfig.resolveAvatarUrl(url)!)
        .toList();
    final sizes = (json['sizes'] as List).cast<String>();
    final colors = (json['colors'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (c) => ProductColorOption(
            c['name'] as String,
            Color(int.parse((c['hex'] as String).replaceFirst('#', '0xFF'))),
          ),
        )
        .toList();
    final queryWords = productName
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .join(',');

    return CoBuySession(
      id: json['id'] as String,
      icon: Icons.shopping_bag_rounded,
      imageQuery: queryWords.isEmpty ? 'product' : queryWords,
      productName: productName,
      category: json['category'] as String? ?? '',
      description: json['description'] as String,
      sellerName: json['seller_name'] as String,
      sellerLocation: (json['seller_location'] as String).isNotEmpty
          ? json['seller_location'] as String
          : 'Cambodia',
      sellerVerified: json['seller_verified'] as bool,
      sellerLogoOverride: ApiConfig.resolveAvatarUrl(
        json['seller_logo_url'] as String?,
      ),
      currentQty: json['current_qty'] as int,
      targetQty: json['target_qty'] as int,
      unitLabel: json['unit_label'] as String,
      perUnitLabel: json['per_unit_label'] as String,
      minOrderQty: json['min_order_qty'] as int,
      retailersJoined: json['retailers_joined'] as int,
      timeLeft: json['time_left'] as String,
      originalPrice: (json['original_price'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      joined: json['joined'] as bool,
      autoRenew: json['auto_renew'] as bool,
      myStatus: json['my_status'] as String?,
      myLeaveAdminNote: json['my_leave_admin_note'] as String?,
      photoUrls: photoUrls,
      sizes: sizes,
      colorOptions: colors,
      weight: json['weight'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      packaging: json['packaging'] as String? ?? '',
    );
  }
}
