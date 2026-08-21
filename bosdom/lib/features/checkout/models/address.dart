class Address {
  const Address({
    required this.id,
    required this.label,
    required this.houseNumber,
    required this.sangkat,
    required this.province,
    required this.phone,
    this.landmark,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String houseNumber;
  final String sangkat;
  final String province;
  final String phone;
  final String? landmark;
  final bool isDefault;

  String get addressLine =>
      [houseNumber, sangkat].where((s) => s.isNotEmpty).join(', ');

  String get cityLine => '$province, Cambodia';

  Address copyWith({bool? isDefault}) => Address(
    id: id,
    label: label,
    houseNumber: houseNumber,
    sangkat: sangkat,
    province: province,
    phone: phone,
    landmark: landmark,
    isDefault: isDefault ?? this.isDefault,
  );
}
