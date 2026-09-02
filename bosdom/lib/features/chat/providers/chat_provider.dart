import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/device_identity_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';

class ChatNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    final userId = await ref.watch(deviceUserIdProvider.future);
    return ChatService.fetchConversations(userId: userId);
  }

  Conversation? byId(String id) {
    final conversations = state.value ?? const [];
    for (final conversation in conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  Future<Conversation> startConversation({
    required String name,
    required bool verified,
  }) async {
    final existing = byId(_slugify(name));
    if (existing != null) return existing;

    final conversation = await ChatService.startConversation(
      name: name,
      verified: verified,
    );
    state = AsyncData([conversation, ...state.value ?? const []]);
    return conversation;
  }

  Future<Conversation> startAdminConversation() async {
    final userId = await ref.read(deviceUserIdProvider.future);
    final existing = byId('admin-$userId');
    if (existing != null) return existing;

    final conversation = await ChatService.startAdminConversation(userId);
    state = AsyncData([conversation, ...state.value ?? const []]);
    return conversation;
  }

  Future<void> markRead(String id) async {
    final conversation = byId(id);
    if (conversation == null || conversation.unreadCount == 0) return;
    conversation.unreadCount = 0;
    state = AsyncData([...state.value ?? const []]);
    await ChatService.markRead(id);
  }

  Future<void> loadConversation(String id) async {
    final full = await ChatService.fetchConversation(id);
    final conversations = <Conversation>[...state.value ?? const []];
    final index = conversations.indexWhere((c) => c.id == id);
    if (index == -1) {
      conversations.insert(0, full);
    } else {
      conversations[index] = full;
    }
    state = AsyncData(conversations);
  }

  Future<void> sendMessage(String id, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final conversation = byId(id);
    if (conversation == null) return;

    conversation.messages.add(
      ChatMessage(sender: MessageSender.me, time: 'Sending...', text: trimmed),
    );
    _bumpToTop(conversation);
    state = AsyncData([...state.value ?? const []]);

    ref.read(chatTypingProvider(id).notifier).state = true;
    final replyMessages = await ChatService.sendMessage(id, trimmed);
    ref.read(chatTypingProvider(id).notifier).state = false;

    conversation.messages
      ..removeLast()
      ..addAll(replyMessages);
    _bumpToTop(conversation);
    state = AsyncData([...state.value ?? const []]);

    ref.read(notificationProvider.notifier).refresh();
  }

  Future<void> sendImage(String id, File file) async {
    final conversation = byId(id);
    if (conversation == null) return;

    conversation.messages.add(
      ChatMessage(
        sender: MessageSender.me,
        time: formatChatTime(DateTime.now()),
        imageFile: file,
      ),
    );
    _bumpToTop(conversation);
    state = AsyncData([...state.value ?? const []]);
  }

  void _bumpToTop(Conversation conversation) {
    final next = <Conversation>[...state.value ?? const []]
      ..remove(conversation);
    next.insert(0, conversation);
    state = AsyncData(next);
  }
}

final chatProvider = AsyncNotifierProvider<ChatNotifier, List<Conversation>>(
  ChatNotifier.new,
);

class _ChatTypingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

/// Whether the other party appears to be "typing" — toggled while a sent
/// message is awaiting its reply, to simulate a realtime chat presence cue.
final chatTypingProvider =
    NotifierProvider.family<_ChatTypingNotifier, bool, String>(
      (id) => _ChatTypingNotifier(),
    );

String _slugify(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
