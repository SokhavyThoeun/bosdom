import '../../../core/config/api_config.dart';
import '../../../shared/utils/mock_images.dart';

class SellerListing {
  const SellerListing({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.category,
    required this.active,
    this.photoUrl,
  });

  final String id;
  final String name;
  final double price;
  final int stockQty;
  final String category;
  final bool active;
  final String? photoUrl;

  /// The listing's real photo when available, else a category-matched mock
  /// photo — mirrors [Product.imageUrl]'s fallback.
  String get imageUrl => photoUrl ?? mockPhotoUrl(category, name);

  SellerListing copyWith({bool? active}) => SellerListing(
    id: id,
    name: name,
    price: price,
    stockQty: stockQty,
    category: category,
    photoUrl: photoUrl,
    active: active ?? this.active,
  );

  factory SellerListing.fromJson(Map<String, dynamic> json) {
    final photoUrls = (json['photo_urls'] as List).cast<String>();
    return SellerListing(
      id: json['id'] as String,
      name: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      stockQty: json['stock_qty'] as int,
      category: json['category'] as String,
      active: json['active'] as bool,
      photoUrl: photoUrls.isNotEmpty
          ? ApiConfig.resolveAvatarUrl(photoUrls.first)
          : null,
    );
  }
}
