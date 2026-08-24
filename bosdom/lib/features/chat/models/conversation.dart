import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../utils/off_platform_detector.dart';

enum MessageSender { me, them }

class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.time,
    this.text,
    this.imageIcon,
    this.imageCaption,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String kind) {
    return ChatMessage(
      sender: json['sender'] == 'me' ? MessageSender.me : MessageSender.them,
      time: _formatTime(DateTime.parse(json['created_at'] as String)),
      text: json['text'] as String?,
      imageIcon: json['image_caption'] != null ? kindToIcon(kind) : null,
      imageCaption: json['image_caption'] as String?,
    );
  }

  final MessageSender sender;
  final String time;
  final String? text;
  final IconData? imageIcon;
  final String? imageCaption;

  bool get flagged => detectsOffPlatformAttempt(text);
}

class Conversation {
  Conversation({
    required this.id,
    required this.name,
    required this.kind,
    required this.verified,
    required this.online,
    required this.unreadCount,
    required List<ChatMessage> messages,
  }) : messages = [...messages];

  factory Conversation.fromSummaryJson(Map<String, dynamic> json) {
    final lastAt = json['last_message_at'] as String?;
    return Conversation(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
      verified: json['verified'] as bool,
      online: json['online'] as bool,
      unreadCount: json['unread_count'] as int,
      messages: [
        if ((json['last_message_preview'] as String).isNotEmpty)
          ChatMessage(
            sender: MessageSender.them,
            time: lastAt != null ? _formatTime(DateTime.parse(lastAt)) : '',
            text: json['last_message_preview'] as String,
          ),
      ],
    );
  }

  factory Conversation.fromDetailJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String;
    return Conversation(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: kind,
      verified: json['verified'] as bool,
      online: json['online'] as bool,
      unreadCount: json['unread_count'] as int,
      messages: (json['messages'] as List)
          .cast<Map<String, dynamic>>()
          .map((m) => ChatMessage.fromJson(m, kind))
          .toList(),
    );
  }

  final String id;
  final String name;
  final String kind;
  final bool verified;
  final bool online;
  int unreadCount;
  final List<ChatMessage> messages;

  IconData get avatarIcon => kindToIcon(kind);
  Color get avatarColor => kindToColor(kind);

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  String get lastMessagePreview {
    final last = lastMessage;
    if (last == null) return '';
    if (last.text != null) return last.text!;
    return '📷 ${last.imageCaption ?? 'Photo'}';
  }
}

IconData kindToIcon(String kind) {
  switch (kind) {
    case 'support':
      return Icons.support_agent_rounded;
    case 'rice':
      return Icons.rice_bowl_outlined;
    case 'textile':
      return Icons.checkroom_outlined;
    case 'handicraft':
      return Icons.palette_outlined;
    case 'grain':
      return Icons.grain_outlined;
    case 'produce':
      return Icons.eco_outlined;
    case 'silk':
      return Icons.diamond_outlined;
    default:
      return Icons.storefront_outlined;
  }
}

Color kindToColor(String kind) {
  switch (kind) {
    case 'support':
      return AppColors.brandCrimson;
    case 'rice':
      return const Color(0xFFC9A05C);
    case 'textile':
      return AppColors.deepBurgundy;
    case 'handicraft':
      return AppColors.alertAmber;
    case 'grain':
      return AppColors.trustGreen;
    case 'produce':
      return const Color(0xFF6FA26E);
    case 'silk':
      return const Color(0xFF8A6A2F);
    default:
      return AppColors.brandCrimson;
  }
}

String _formatTime(DateTime dateTime) {
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
