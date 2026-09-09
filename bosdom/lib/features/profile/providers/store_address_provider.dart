import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/store_address.dart';

class StoreAddressNotifier extends Notifier<List<StoreAddress>> {
  @override
  List<StoreAddress> build() => [];

  void addAddress(StoreAddress address) {
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

final storeAddressBookProvider =
    NotifierProvider<StoreAddressNotifier, List<StoreAddress>>(
      StoreAddressNotifier.new,
    );

final defaultStoreAddressProvider = Provider<StoreAddress?>((ref) {
  final addresses = ref.watch(storeAddressBookProvider);
  if (addresses.isEmpty) return null;
  return addresses.firstWhere(
    (a) => a.isDefault,
    orElse: () => addresses.first,
  );
});
