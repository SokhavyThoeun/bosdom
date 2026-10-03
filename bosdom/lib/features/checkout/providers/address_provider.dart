import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../services/address_service.dart';

/// Where the address book lived before it moved to the backend.
const _kLegacyAddressBookKey = 'address_book_v1';

/// The fake entry older app versions seeded the book with — never uploaded.
const _kLegacySeedId = 'seed-1';

class AddressNotifier extends AsyncNotifier<List<Address>> {
  @override
  Future<List<Address>> build() async =>
      _migrateLegacy(await AddressService.fetch());

  /// One-time upload of addresses saved on-device by older app versions,
  /// so they aren't lost now that the backend is the source of truth.
  Future<List<Address>> _migrateLegacy(List<Address> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLegacyAddressBookKey);
    if (raw == null) return addresses;
    var result = addresses;
    try {
      for (final e in jsonDecode(raw) as List) {
        final address = Address.fromJson(e as Map<String, dynamic>);
        if (address.id == _kLegacySeedId) continue;
        result = await AddressService.add(address);
      }
    } on FormatException {
      // Corrupt payload — nothing recoverable to migrate.
    }
    await prefs.remove(_kLegacyAddressBookKey);
    return result;
  }

  /// Applies [optimistic] immediately, then replaces it with the server's
  /// book; reverts and rethrows if the request fails so callers can say so.
  Future<void> _mutate(
    List<Address> optimistic,
    Future<List<Address>> Function() request,
  ) async {
    final previous = state.value ?? const [];
    state = AsyncData(optimistic);
    try {
      state = AsyncData(await request());
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  List<Address> get _current => state.value ?? const [];

  Future<void> addAddress(Address address) => _mutate([
    for (final existing in _current)
      address.isDefault ? existing.copyWith(isDefault: false) : existing,
    address,
  ], () => AddressService.add(address));

  Future<void> updateAddress(Address address) => _mutate([
    for (final existing in _current)
      if (existing.id == address.id)
        address
      else
        existing.copyWith(isDefault: address.isDefault ? false : null),
  ], () => AddressService.update(address));

  Future<void> deleteAddress(String id) => _mutate([
    for (final existing in _current)
      if (existing.id != id) existing,
  ], () => AddressService.delete(id));

  Future<void> setDefault(String id) => _mutate([
    for (final existing in _current)
      existing.copyWith(isDefault: existing.id == id),
  ], () => AddressService.setDefault(id));
}

final addressBookProvider =
    AsyncNotifierProvider<AddressNotifier, List<Address>>(AddressNotifier.new);

final defaultAddressProvider = Provider<Address?>((ref) {
  final addresses = ref.watch(addressBookProvider).value ?? const [];
  if (addresses.isEmpty) return null;
  return addresses.firstWhere(
    (a) => a.isDefault,
    orElse: () => addresses.first,
  );
});
