import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store_address.dart';

const _kStoreAddressBookKey = 'store_address_book_v1';

class StoreAddressNotifier extends Notifier<List<StoreAddress>> {
  @override
  List<StoreAddress> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStoreAddressBookKey);
    if (raw == null) return;
    try {
      state = [
        for (final e in jsonDecode(raw) as List)
          StoreAddress.fromJson(e as Map<String, dynamic>),
      ];
    } on Object {
      // Corrupt payload — start empty rather than crash on startup.
    }
  }

  void _persist() {
    final encoded = jsonEncode([for (final a in state) a.toJson()]);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_kStoreAddressBookKey, encoded),
    );
  }

  void addAddress(StoreAddress address) {
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

  void updateAddress(StoreAddress address) {
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

  void setDefault(String id) {
    state = [
      for (final existing in state)
        existing.copyWith(isDefault: existing.id == id),
    ];
    _persist();
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
