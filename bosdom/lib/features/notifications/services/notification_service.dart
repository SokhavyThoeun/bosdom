import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/app_notification.dart';

class NotificationsPage {
  const NotificationsPage({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;
}

abstract final class NotificationService {
  static Future<NotificationsPage> fetchAll() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifications'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return NotificationsPage(
      items: (body['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(),
      unreadCount: body['unread_count'] as int,
    );
  }

  static Future<int> markRead(String id) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification read: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['unread_count'] as int;
  }

  static Future<void> markAllRead() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications read: ${response.body}');
    }
  }
}
