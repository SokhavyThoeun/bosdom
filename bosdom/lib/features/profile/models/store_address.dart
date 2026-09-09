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

  String get cityLine => '$province, Cambodia';

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
}
