import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/conversation.dart';

abstract final class ChatService {
  static Future<List<Conversation>> fetchConversations({String? userId}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/chat/conversations').replace(
      queryParameters: userId != null ? {'user_id': userId} : null,
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversations: ${response.body}');
    }

    final body = jsonDecode(response.body) as List;
    return body
        .cast<Map<String, dynamic>>()
        .map(Conversation.fromSummaryJson)
        .toList();
  }

  static Future<Conversation> startAdminConversation(String userId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/admin/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to start admin conversation: ${response.body}');
    }

    return Conversation.fromSummaryJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<Conversation> startConversation({
    required String name,
    required bool verified,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'verified': verified}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to start conversation: ${response.body}');
    }

    return Conversation.fromSummaryJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<Conversation> fetchConversation(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversation: ${response.body}');
    }

    return Conversation.fromDetailJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<void> markRead(String id) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$id/read'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark conversation read: ${response.body}');
    }
  }

  static Future<List<ChatMessage>> sendMessage(String id, String text) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$id/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['messages'] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => ChatMessage.fromJson(m, ''))
        .toList();
  }
}
