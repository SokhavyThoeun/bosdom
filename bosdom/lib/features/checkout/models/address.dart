class Address {
  const Address({
    required this.id,
    required this.label,
    required this.houseNumber,
    required this.sangkat,
    required this.province,
    required this.phone,
    this.landmark,
    this.district,
    this.sangkatName,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String houseNumber;
  final String sangkat;
  final String province;
  final String phone;
  final String? landmark;

  /// Raw dropdown selections, kept so the edit form can prefill them.
  final String? district;
  final String? sangkatName;
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
    district: district,
    sangkatName: sangkatName,
    isDefault: isDefault ?? this.isDefault,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'houseNumber': houseNumber,
    'sangkat': sangkat,
    'province': province,
    'phone': phone,
    'landmark': landmark,
    'district': district,
    'sangkatName': sangkatName,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    label: json['label'] as String,
    houseNumber: json['houseNumber'] as String? ?? '',
    sangkat: json['sangkat'] as String? ?? '',
    province: json['province'] as String,
    phone: json['phone'] as String? ?? '',
    landmark: json['landmark'] as String?,
    district: json['district'] as String?,
    sangkatName: json['sangkatName'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
  );
}
