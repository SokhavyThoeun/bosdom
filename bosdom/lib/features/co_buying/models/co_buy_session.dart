import 'package:flutter/material.dart';

import '../../../shared/models/variant_option.dart';
import '../../../shared/utils/mock_images.dart';

enum CoBuyDealStatus { active, completed, expired }

class CoBuySession {
  CoBuySession({
    required this.id,
    required this.icon,
    required this.imageQuery,
    required this.productName,
    required this.sellerName,
    required this.sellerRating,
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
    this.description = '',
    this.autoRenew = false,
    this.imagePaths = const [],
    this.sizes = const [],
    this.colorOptions = const [],
  });

  final String id;
  final IconData icon;

  /// Keyword(s) used to fetch a topic-matched mock product photo.
  final String imageQuery;
  final String productName;
  final String description;
  final String sellerName;
  final double sellerRating;
  final String sellerLocation;
  final bool sellerVerified;
  final int targetQty;
  final String unitLabel;
  final String perUnitLabel;
  final int minOrderQty;
  final String timeLeft;
  final double originalPrice;
  final double price;
  final bool autoRenew;

  /// Local device paths to seller-picked product photos (first is the
  /// cover). Falls back to [imageUrl]'s curated mock photo when empty.
  final List<String> imagePaths;

  /// The cover photo — the first entry in [imagePaths], if any.
  String? get imagePath => imagePaths.isNotEmpty ? imagePaths.first : null;

  /// Selectable sizes (e.g. clothing). Empty when the session has no size
  /// variants.
  final List<String> sizes;

  /// Selectable colors. Empty when the session has no color variants.
  final List<ProductColorOption> colorOptions;

  int currentQty;
  int retailersJoined;
  bool joined;

  bool get hasVariants => sizes.isNotEmpty || colorOptions.isNotEmpty;

  double get progress => currentQty / targetQty;
  int get remainingQty => targetQty - currentQty;
  bool get isFull => currentQty >= targetQty;
  int get savingsPct =>
      (((originalPrice - price) / originalPrice) * 100).round();

  /// A deal that ran out of time without reaching its target is tagged by
  /// putting "expired" in [timeLeft] — there's no separate deadline clock in
  /// this mock data model.
  CoBuyDealStatus get dealStatus {
    if (timeLeft.toLowerCase().contains('expired')) {
      return CoBuyDealStatus.expired;
    }
    if (isFull) return CoBuyDealStatus.completed;
    return CoBuyDealStatus.active;
  }

  /// Topic-matched mock product photo.
  String get imageUrl => mockPhotoUrl(imageQuery, id);

  /// Clean mock logo for this session's seller/store.
  String get sellerLogoUrl => mockStoreLogoUrl(sellerName);
}
