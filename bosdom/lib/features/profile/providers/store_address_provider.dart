import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store_address.dart';
import '../services/store_address_service.dart';
import 'shop_profile_provider.dart';

/// Where the address book lived before it moved to the backend.
const _kLegacyStoreAddressBookKey = 'store_address_book_v1';

class StoreAddressNotifier extends AsyncNotifier<List<StoreAddress>> {
  @override
  Future<List<StoreAddress>> build() async {
    final addresses = await _migrateLegacy(await StoreAddressService.fetch());
    _refreshShop();
    return addresses;
  }

  /// The backend mirrors the default address into the shop's public
  /// location, so drop cached shop info for View Shop / About to refetch.
  void _refreshShop() {
    ref.invalidate(shopProfileProvider);
    ref.invalidate(shopProfileByIdProvider);
  }

  /// One-time upload of addresses saved on-device by older app versions,
  /// so they aren't lost now that the backend is the source of truth.
  Future<List<StoreAddress>> _migrateLegacy(
    List<StoreAddress> addresses,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLegacyStoreAddressBookKey);
    if (raw == null) return addresses;
    var result = addresses;
    try {
      for (final e in jsonDecode(raw) as List) {
        result = await StoreAddressService.add(
          StoreAddress.fromJson(e as Map<String, dynamic>),
        );
      }
    } on FormatException {
      // Corrupt payload — nothing recoverable to migrate.
    }
    await prefs.remove(_kLegacyStoreAddressBookKey);
    return result;
  }

  /// Applies [optimistic] immediately, then replaces it with the server's
  /// book; reverts and rethrows if the request fails so callers can say so.
  Future<void> _mutate(
    List<StoreAddress> optimistic,
    Future<List<StoreAddress>> Function() request,
  ) async {
    final previous = state.value ?? const [];
    state = AsyncData(optimistic);
    try {
      state = AsyncData(await request());
      _refreshShop();
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  List<StoreAddress> get _current => state.value ?? const [];

  Future<void> addAddress(StoreAddress address) => _mutate([
    for (final existing in _current)
      address.isDefault ? existing.copyWith(isDefault: false) : existing,
    address,
  ], () => StoreAddressService.add(address));

  Future<void> updateAddress(StoreAddress address) => _mutate([
    for (final existing in _current)
      if (existing.id == address.id)
        address
      else
        existing.copyWith(isDefault: address.isDefault ? false : null),
  ], () => StoreAddressService.update(address));

  Future<void> deleteAddress(String id) => _mutate([
    for (final existing in _current)
      if (existing.id != id) existing,
  ], () => StoreAddressService.delete(id));

  Future<void> setDefault(String id) => _mutate([
    for (final existing in _current)
      existing.copyWith(isDefault: existing.id == id),
  ], () => StoreAddressService.setDefault(id));
}

final storeAddressBookProvider =
    AsyncNotifierProvider<StoreAddressNotifier, List<StoreAddress>>(
      StoreAddressNotifier.new,
    );

final defaultStoreAddressProvider = Provider<StoreAddress?>((ref) {
  final addresses = ref.watch(storeAddressBookProvider).value ?? const [];
  if (addresses.isEmpty) return null;
  return addresses.firstWhere(
    (a) => a.isDefault,
    orElse: () => addresses.first,
  );
});
