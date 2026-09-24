import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDeviceUserIdKey = 'device_user_id';

class DeviceIdentityNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kDeviceUserIdKey);
    if (existing != null) return existing;

    final id = _generateId();
    await prefs.setString(_kDeviceUserIdKey, id);
    return id;
  }

  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Anonymous id persisted locally to identify this user to the admin chat
/// until real account auth lands.
final deviceUserIdProvider =
    AsyncNotifierProvider<DeviceIdentityNotifier, String>(
      DeviceIdentityNotifier.new,
    );
