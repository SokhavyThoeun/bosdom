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

  /// The backend's payload shape (server assigns the id on create).
  Map<String, dynamic> toJson() => {
    'label': label,
    'house_number': houseNumber,
    'sangkat': sangkat,
    'province': province,
    'phone': phone,
    'landmark': landmark,
    'district': district,
    'sangkat_name': sangkatName,
    'is_default': isDefault,
  };

  /// Reads the backend's snake_case shape, falling back to the camelCase
  /// keys the old device-only address book saved (migrated on first load).
  factory Address.fromJson(Map<String, dynamic> json) {
    T? pick<T>(String snake, String camel) =>
        (json[snake] ?? json[camel]) as T?;
    return Address(
      id: json['id'] as String? ?? '',
      label: pick<String>('label', 'label') ?? '',
      houseNumber: pick<String>('house_number', 'houseNumber') ?? '',
      sangkat: pick<String>('sangkat', 'sangkat') ?? '',
      province: pick<String>('province', 'province') ?? '',
      phone: pick<String>('phone', 'phone') ?? '',
      landmark: pick<String>('landmark', 'landmark'),
      district: pick<String>('district', 'district'),
      sangkatName: pick<String>('sangkat_name', 'sangkatName'),
      isDefault: pick<bool>('is_default', 'isDefault') ?? false,
    );
  }
}
