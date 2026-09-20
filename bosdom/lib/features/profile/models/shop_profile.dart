class ShopProfile {
  const ShopProfile({
    required this.shopName,
    required this.businessType,
    required this.yearEstablished,
    required this.location,
    required this.phone,
    required this.email,
    required this.description,
    this.storeType = '',
    this.storeUrl = '',
    this.logoUrl = '',
    this.photoUrls = const [],
    this.highVolume = false,
  });

  factory ShopProfile.fromJson(Map<String, dynamic> json) => ShopProfile(
    shopName: json['shop_name'] as String? ?? '',
    businessType: json['business_type'] as String? ?? '',
    storeType: json['store_type'] as String? ?? '',
    yearEstablished: json['year_established'] as String? ?? '',
    location: json['location'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    description: json['description'] as String? ?? '',
    storeUrl: json['store_url'] as String? ?? '',
    logoUrl: json['logo_url'] as String? ?? '',
    photoUrls:
        (json['photo_urls'] as List<dynamic>?)?.cast<String>() ?? const [],
    highVolume: json['high_volume'] as bool? ?? false,
  );

  final String shopName;
  final String businessType;
  final String storeType;
  final String yearEstablished;
  final String location;
  final String phone;
  final String email;
  final String description;
  final String storeUrl;
  final String logoUrl;
  final List<String> photoUrls;

  /// Earned the "Power Seller" badge (more than 40 confirmed orders in a
  /// month) — set by the backend, never edited by the seller.
  final bool highVolume;

  Map<String, dynamic> toJson() => {
    'shop_name': shopName,
    'business_type': businessType,
    'store_type': storeType,
    'year_established': yearEstablished,
    'location': location,
    'phone': phone,
    'email': email,
    'description': description,
    'store_url': storeUrl,
  };

  ShopProfile copyWith({
    String? shopName,
    String? businessType,
    String? storeType,
    String? yearEstablished,
    String? location,
    String? phone,
    String? email,
    String? description,
    String? storeUrl,
    String? logoUrl,
    List<String>? photoUrls,
  }) => ShopProfile(
    shopName: shopName ?? this.shopName,
    businessType: businessType ?? this.businessType,
    storeType: storeType ?? this.storeType,
    yearEstablished: yearEstablished ?? this.yearEstablished,
    location: location ?? this.location,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    description: description ?? this.description,
    storeUrl: storeUrl ?? this.storeUrl,
    logoUrl: logoUrl ?? this.logoUrl,
    photoUrls: photoUrls ?? this.photoUrls,
    highVolume: highVolume,
  );
}
