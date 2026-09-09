import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';

// Shown only when the backend is unreachable and there's no cached profile
// yet for this account (e.g. first run offline).
const _kFallbackProfile = UserProfile(
  name: '',
  phone: '',
  role: 'retailer',
  email: '',
);

String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

// Namespaced per Supabase user id so a cached profile never leaks across
// different Google accounts signed into the same device.
String _cacheKey(String userId) => 'cached_profile_$userId';

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    try {
      final profile = await ProfileService.fetch();
      await _cache(profile);
      return profile;
    } catch (_) {
      // Backend unreachable (e.g. dev LAN IP changed) — fall back to the
      // last profile fetched for this Google account instead of showing a
      // blank profile that looks like the account needs re-onboarding.
      return await _readCache() ?? _kFallbackProfile;
    }
  }

  /// Re-fetches from the backend for pull-to-refresh. Leaves the current
  /// profile on screen if the request fails, and rethrows so the caller can
  /// surface an error.
  Future<void> refresh() async {
    final profile = await ProfileService.fetch();
    await _cache(profile);
    state = AsyncData(profile);
  }

  Future<void> save(UserProfile profile) async {
    final previous = state.value;
    state = AsyncData(profile);

    try {
      final saved = await ProfileService.save(profile);
      await _cache(saved);
      state = AsyncData(saved);
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> uploadAvatar(File file) async {
    final updated = await ProfileService.uploadAvatar(file);
    await _cache(updated);
    state = AsyncData(updated);
  }

  Future<void> _cache(UserProfile profile) async {
    final userId = _currentUserId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey(userId),
      jsonEncode({
        'name': profile.name,
        'phone': profile.phone,
        'role': profile.role,
        'email': profile.email,
        'avatar_url': profile.avatarUrl,
      }),
    );
  }

  Future<UserProfile?> _readCache() async {
    final userId = _currentUserId;
    if (userId == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(userId));
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
