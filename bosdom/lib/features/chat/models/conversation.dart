import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.isMine,
    required this.createdAt,
    this.text,
    this.flagged = false,
    this.imageFile,
    this.sending = false,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = json['sender_id'] as String;
    return ChatMessage(
      id: json['id'] as String,
      senderId: senderId,
      isMine: senderId == currentUserId,
      createdAt: DateTime.parse(json['created_at'] as String),
      text: json['text'] as String?,
      flagged: json['flagged'] as bool? ?? false,
    );
  }

  final String id;
  final String senderId;
  final bool isMine;
  final DateTime createdAt;
  final String? text;
  final bool flagged;

  /// Locally attached photo (picked from camera/gallery). There is no
  /// image-message endpoint on the backend, so this never leaves the
  /// device — same known limitation as before this screen was wired up.
  final File? imageFile;

  /// True while an optimistically-appended message is awaiting the
  /// server's response.
  final bool sending;

  String get time => formatChatTime(createdAt);
}

class Conversation {
  Conversation({
    required this.id,
    required this.counterpartId,
    required this.counterpartName,
    required this.counterpartVerified,
    required this.listingId,
    required this.unreadCount,
    required List<ChatMessage> messages,
  }) : messages = [...messages];

  factory Conversation.fromSummaryJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final lastAt = json['last_message_at'] as String?;
    final preview = json['last_message_preview'] as String;
    return Conversation(
      id: json['id'] as String,
      counterpartId: json['counterpart_id'] as String,
      counterpartName: json['counterpart_name'] as String,
      counterpartVerified: json['counterpart_verified'] as bool,
      listingId: json['listing_id'] as String?,
      unreadCount: json['unread_count'] as int,
      messages: [
        if (preview.isNotEmpty && lastAt != null)
          ChatMessage(
            id: 'preview',
            senderId: '',
            isMine: false,
            createdAt: DateTime.parse(lastAt),
            text: preview,
          ),
      ],
    );
  }

  /// The backend's conversation-detail response has no `unread_count` (the
  /// caller is expected to mark the thread read right after loading it), so
  /// this defaults to 0 — callers that need to preserve a known unread
  /// count should overwrite it after construction.
  factory Conversation.fromDetailJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    return Conversation(
      id: json['id'] as String,
      counterpartId: json['counterpart_id'] as String,
      counterpartName: json['counterpart_name'] as String,
      counterpartVerified: json['counterpart_verified'] as bool,
      listingId: json['listing_id'] as String?,
      unreadCount: 0,
      messages: (json['messages'] as List)
          .cast<Map<String, dynamic>>()
          .map((m) => ChatMessage.fromJson(m, currentUserId: currentUserId))
          .toList(),
    );
  }

  final String id;
  final String counterpartId;
  final String counterpartName;
  final bool counterpartVerified;
  final String? listingId;
  int unreadCount;
  final List<ChatMessage> messages;

  IconData get avatarIcon => avatarIconFor(counterpartName);
  Color get avatarColor => avatarColorFor(counterpartName);

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  String get lastMessagePreview {
    final last = lastMessage;
    if (last == null) return '';
    if (last.text != null) return last.text!;
    if (last.imageFile != null) return '📷 Photo';
    return '';
  }
}

const _kAvatarIcons = [
  Icons.storefront_outlined,
  Icons.rice_bowl_outlined,
  Icons.checkroom_outlined,
  Icons.palette_outlined,
  Icons.grain_outlined,
  Icons.eco_outlined,
  Icons.diamond_outlined,
];

const _kAvatarColors = [
  AppColors.brandCrimson,
  Color(0xFFC9A05C),
  AppColors.deepBurgundy,
  AppColors.alertAmber,
  AppColors.trustGreen,
  Color(0xFF6FA26E),
  Color(0xFF8A6A2F),
];

/// Deterministic avatar icon/color for a counterpart, since real
/// conversations have no seller "kind" concept to key off of.
IconData avatarIconFor(String key) =>
    _kAvatarIcons[key.hashCode.abs() % _kAvatarIcons.length];

Color avatarColorFor(String key) =>
    _kAvatarColors[key.hashCode.abs() % _kAvatarColors.length];

String formatChatTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final isToday =
      local.year == now.year && local.month == now.month && local.day == now.day;
  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday =
      local.year == yesterday.year &&
      local.month == yesterday.month &&
      local.day == yesterday.day;

  if (isToday) {
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  if (isYesterday) return 'Yesterday';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[local.month - 1]} ${local.day}';
}
