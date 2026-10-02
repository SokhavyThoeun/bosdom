class StoreAddress {
  const StoreAddress({
    required this.id,
    required this.label,
    required this.storeName,
    required this.businessType,
    required this.fullAddress,
    required this.district,
    required this.province,
    required this.phone,
    required this.email,
    required this.operatingHours,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String storeName;
  final String businessType;
  final String fullAddress;
  final String district;
  final String province;
  final String phone;
  final String email;
  final String operatingHours;
  final bool isDefault;

  String get addressLine =>
      [fullAddress, district].where((s) => s.isNotEmpty).join(', ');

  String get cityLine => province.isEmpty ? 'Cambodia' : '$province, Cambodia';

  StoreAddress copyWith({bool? isDefault}) => StoreAddress(
    id: id,
    label: label,
    storeName: storeName,
    businessType: businessType,
    fullAddress: fullAddress,
    district: district,
    province: province,
    phone: phone,
    email: email,
    operatingHours: operatingHours,
    isDefault: isDefault ?? this.isDefault,
  );

  /// The backend's payload shape (server assigns the id on create).
  Map<String, dynamic> toJson() => {
    'label': label,
    'store_name': storeName,
    'business_type': businessType,
    'full_address': fullAddress,
    'district': district,
    'province': province,
    'phone': phone,
    'email': email,
    'operating_hours': operatingHours,
    'is_default': isDefault,
  };

  /// Reads the backend's snake_case shape, falling back to the camelCase
  /// keys the old device-only address book saved (migrated on first load).
  factory StoreAddress.fromJson(Map<String, dynamic> json) {
    String str(String snake, String camel) =>
        (json[snake] ?? json[camel]) as String? ?? '';
    return StoreAddress(
      id: json['id'] as String? ?? '',
      label: str('label', 'label'),
      storeName: str('store_name', 'storeName'),
      businessType: str('business_type', 'businessType'),
      fullAddress: str('full_address', 'fullAddress'),
      district: str('district', 'district'),
      province: str('province', 'province'),
      phone: str('phone', 'phone'),
      email: str('email', 'email'),
      operatingHours: str('operating_hours', 'operatingHours'),
      isDefault: (json['is_default'] ?? json['isDefault']) as bool? ?? false,
    );
  }
}
