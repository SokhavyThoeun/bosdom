import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';

const _kAddressBookKey = 'address_book_v1';

class AddressNotifier extends Notifier<List<Address>> {
  @override
  List<Address> build() {
    _load();
    return _seed;
  }

  static const _seed = [
    Address(
      id: 'seed-1',
      label: 'Warehouse District 7',
      houseNumber: '',
      sangkat: '',
      province: 'Phnom Penh',
      phone: '+855 12 345 678',
      isDefault: true,
    ),
  ];

  /// Replaces the seed with the saved address book, if one was ever saved.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAddressBookKey);
    if (raw == null) return;
    try {
      state = [
        for (final e in jsonDecode(raw) as List)
          Address.fromJson(e as Map<String, dynamic>),
      ];
    } on Object {
      // Corrupt payload — keep the seed rather than crash on startup.
    }
  }

  void _persist() {
    final encoded = jsonEncode([for (final a in state) a.toJson()]);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_kAddressBookKey, encoded),
    );
  }

  void addAddress(Address address) {
    if (address.isDefault) {
      state = [
        for (final existing in state) existing.copyWith(isDefault: false),
        address,
      ];
    } else {
      state = [...state, address];
    }
    _persist();
  }

  void setDefault(String id) {
    state = [
      for (final existing in state)
        existing.copyWith(isDefault: existing.id == id),
    ];
    _persist();
  }

  void updateAddress(Address address) {
    state = [
      for (final existing in state)
        if (existing.id == address.id)
          address
        else
          existing.copyWith(isDefault: address.isDefault ? false : null),
    ];
    _ensureDefault();
    _persist();
  }

  void deleteAddress(String id) {
    state = [
      for (final existing in state)
        if (existing.id != id) existing,
    ];
    _ensureDefault();
    _persist();
  }

  /// Keeps one address flagged default whenever the book is non-empty.
  void _ensureDefault() {
    if (state.isEmpty || state.any((a) => a.isDefault)) return;
    state = [state.first.copyWith(isDefault: true), ...state.skip(1)];
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
