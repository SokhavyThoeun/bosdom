class ShopProfile {
  const ShopProfile({
    required this.shopName,
    required this.businessType,
    required this.yearEstablished,
    required this.location,
    required this.phone,
    required this.email,
    required this.description,
    this.logoUrl = '',
  });

  factory ShopProfile.fromJson(Map<String, dynamic> json) => ShopProfile(
    shopName: json['shop_name'] as String? ?? '',
    businessType: json['business_type'] as String? ?? '',
    yearEstablished: json['year_established'] as String? ?? '',
    location: json['location'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    description: json['description'] as String? ?? '',
    logoUrl: json['logo_url'] as String? ?? '',
  );

  final String shopName;
  final String businessType;
  final String yearEstablished;
  final String location;
  final String phone;
  final String email;
  final String description;
  final String logoUrl;

  Map<String, dynamic> toJson() => {
    'shop_name': shopName,
    'business_type': businessType,
    'year_established': yearEstablished,
    'location': location,
    'phone': phone,
    'email': email,
    'description': description,
  };

  ShopProfile copyWith({
    String? shopName,
    String? businessType,
    String? yearEstablished,
    String? location,
    String? phone,
    String? email,
    String? description,
    String? logoUrl,
  }) => ShopProfile(
    shopName: shopName ?? this.shopName,
    businessType: businessType ?? this.businessType,
    yearEstablished: yearEstablished ?? this.yearEstablished,
    location: location ?? this.location,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    description: description ?? this.description,
    logoUrl: logoUrl ?? this.logoUrl,
  );
}
