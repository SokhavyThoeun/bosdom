import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/chat_service.dart';

/// Backed by the real `chat_tos_accepted_at` flag on the buyer/seller's
/// profile (`GET/POST /chat/tos/*`) — the same flag `POST
/// /chat/conversations/{id}/messages` enforces server-side, so this gate
/// and the backend can no longer disagree the way the old local-prefs-only
/// gate could.
class ChatPolicyNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ChatService.fetchTosAccepted();

  Future<void> accept() async {
    await ChatService.acceptTos();
    state = const AsyncData(true);
  }
}

final chatPolicyProvider = AsyncNotifierProvider<ChatPolicyNotifier, bool>(
  ChatPolicyNotifier.new,
);
