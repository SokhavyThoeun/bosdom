import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/device_identity_provider.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

// Shown instead of a blank screen if the backend is briefly unreachable
// (e.g. dev machine's LAN IP changed) — save() still tries the real backend.
const _kFallbackProfile = UserProfile(
  name: '',
  phone: '',
  role: 'retailer',
  email: '',
);

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final userId = await ref.watch(deviceUserIdProvider.future);
    try {
      return await ProfileService.fetch(userId);
    } catch (_) {
      return _kFallbackProfile;
    }
  }

  Future<void> save(UserProfile profile) async {
    final previous = state.value;
    state = AsyncData(profile);

    try {
      final userId = await ref.read(deviceUserIdProvider.future);
      final saved = await ProfileService.save(userId, profile);
      state = AsyncData(saved);
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> uploadAvatar(File file) async {
    final userId = await ref.read(deviceUserIdProvider.future);
    final updated = await ProfileService.uploadAvatar(userId, file);
    state = AsyncData(updated);
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
