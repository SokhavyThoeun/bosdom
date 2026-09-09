import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../notifications/providers/notification_provider.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';

class ChatNotifier extends AsyncNotifier<List<Conversation>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Conversation>> build() async {
    final existingChannel = _channel;
    if (existingChannel != null) {
      Supabase.instance.client.removeChannel(existingChannel);
      _channel = null;
    }
    ref.onDispose(() {
      final channel = _channel;
      if (channel != null) Supabase.instance.client.removeChannel(channel);
    });

    final conversations = await ChatService.fetchConversations();
    _subscribeToMessages();
    return conversations;
  }

  /// Live message delivery: subscribes to every `messages` insert visible
  /// to this user (Supabase RLS already scopes rows to the two
  /// participants of each conversation, per the Phase 14.3 migration), so
  /// a message the other side sends shows up here without polling.
  void _subscribeToMessages() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    _channel = Supabase.instance.client
        .channel('chat-messages-$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) =>
              _onMessageInserted(payload.newRecord, currentUserId),
        )
        .subscribe();
  }

  Future<void> _onMessageInserted(
    Map<String, dynamic> record,
    String currentUserId,
  ) async {
    final conversationId = record['conversation_id'] as String?;
    if (conversationId == null) return;

    final message = ChatMessage.fromJson(record, currentUserId: currentUserId);
    if (message.isMine) return; // already appended optimistically by us

    final conversations = <Conversation>[...state.value ?? const []];
    final index = conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) {
      // A brand-new conversation someone else just started — refetch.
      state = AsyncData(await ChatService.fetchConversations());
      return;
    }

    final conversation = conversations.removeAt(index)
      ..messages.add(message)
      ..unreadCount += 1;
    conversations.insert(0, conversation);
    state = AsyncData(conversations);
    ref.read(notificationProvider.notifier).refresh();
  }

  Conversation? byId(String id) {
    for (final conversation in state.value ?? const <Conversation>[]) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  Future<Conversation> startConversation({
    required String counterpartId,
    String? listingId,
  }) async {
    for (final conversation in state.value ?? const <Conversation>[]) {
      if (conversation.counterpartId == counterpartId) return conversation;
    }

    final conversation = await ChatService.startConversation(
      counterpartId: counterpartId,
      listingId: listingId,
    );
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
      full.unreadCount = conversations[index].unreadCount;
      conversations[index] = full;
    }
    state = AsyncData(conversations);
  }

  Future<void> sendMessage(String id, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final conversation = byId(id);
    if (conversation == null) return;

    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final optimisticId = 'pending-${DateTime.now().microsecondsSinceEpoch}';
    conversation.messages.add(
      ChatMessage(
        id: optimisticId,
        senderId: currentUserId,
        isMine: true,
        createdAt: DateTime.now(),
        text: trimmed,
        sending: true,
      ),
    );
    _bumpToTop(conversation);
    state = AsyncData([...state.value ?? const []]);

    try {
      final sent = await ChatService.sendMessage(id, trimmed);
      final index = conversation.messages.indexWhere(
        (m) => m.id == optimisticId,
      );
      if (index != -1) conversation.messages[index] = sent;
      state = AsyncData([...state.value ?? const []]);
    } catch (_) {
      conversation.messages.removeWhere((m) => m.id == optimisticId);
      state = AsyncData([...state.value ?? const []]);
      rethrow;
    }
  }

  Future<void> sendImage(String id, File file) async {
    final conversation = byId(id);
    if (conversation == null) return;

    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    conversation.messages.add(
      ChatMessage(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        senderId: currentUserId,
        isMine: true,
        createdAt: DateTime.now(),
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
