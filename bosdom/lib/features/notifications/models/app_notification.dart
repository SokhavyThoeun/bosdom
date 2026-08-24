import 'package:flutter/material.dart';

enum NotificationCategory { chat, order, coBuy, escrow, payment, system }

class NotificationTarget {
  const NotificationTarget({required this.route, this.params = const {}});

  factory NotificationTarget.fromJson(Map<String, dynamic> json) {
    return NotificationTarget(
      route: json['route'] as String,
      params: (json['params'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
  }

  final String route;
  final Map<String, String> params;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    this.target,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      category: _categoryFromJson(json['category'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      read: json['read'] as bool,
      target: json['target'] != null
          ? NotificationTarget.fromJson(json['target'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final NotificationCategory category;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final NotificationTarget? target;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    category: category,
    title: title,
    body: body,
    createdAt: createdAt,
    read: read ?? this.read,
    target: target,
  );

  IconData get icon {
    switch (category) {
      case NotificationCategory.chat:
        return Icons.chat_bubble_outline;
      case NotificationCategory.order:
        return Icons.local_shipping_outlined;
      case NotificationCategory.coBuy:
        return Icons.groups_outlined;
      case NotificationCategory.escrow:
        return Icons.verified_user_outlined;
      case NotificationCategory.payment:
        return Icons.payments_outlined;
      case NotificationCategory.system:
        return Icons.info_outline;
    }
  }

  String get relativeTime {
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.toLocal().month}/${createdAt.toLocal().day}';
  }
}

NotificationCategory _categoryFromJson(String value) {
  switch (value) {
    case 'chat':
      return NotificationCategory.chat;
    case 'order':
      return NotificationCategory.order;
    case 'co_buy':
      return NotificationCategory.coBuy;
    case 'escrow':
      return NotificationCategory.escrow;
    case 'payment':
      return NotificationCategory.payment;
    default:
      return NotificationCategory.system;
  }
}
