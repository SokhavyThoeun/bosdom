import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address.dart';

class AddressNotifier extends Notifier<List<Address>> {
  @override
  List<Address> build() => [
    const Address(
      id: 'seed-1',
      label: 'Warehouse District 7',
      houseNumber: '',
      sangkat: '',
      province: 'Phnom Penh',
      phone: '+855 12 345 678',
      isDefault: true,
    ),
  ];

  void addAddress(Address address) {
    if (address.isDefault) {
      state = [
        for (final existing in state) existing.copyWith(isDefault: false),
        address,
      ];
    } else {
      state = [...state, address];
    }
  }

  void setDefault(String id) {
    state = [
      for (final existing in state)
        existing.copyWith(isDefault: existing.id == id),
    ];
  }
}

final addressBookProvider = NotifierProvider<AddressNotifier, List<Address>>(
  AddressNotifier.new,
);

final defaultAddressProvider = Provider<Address?>((ref) {
  final addresses = ref.watch(addressBookProvider);
  if (addresses.isEmpty) return null;
  return addresses.firstWhere(
    (a) => a.isDefault,
    orElse: () => addresses.first,
  );
});
