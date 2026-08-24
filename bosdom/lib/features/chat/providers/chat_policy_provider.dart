import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kChatTosAcceptedKey = 'chat_tos_accepted';

class ChatPolicyNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kChatTosAcceptedKey) ?? false;
  }

  Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kChatTosAcceptedKey, true);
    state = const AsyncData(true);
  }
}

final chatPolicyProvider = AsyncNotifierProvider<ChatPolicyNotifier, bool>(
  ChatPolicyNotifier.new,
);
