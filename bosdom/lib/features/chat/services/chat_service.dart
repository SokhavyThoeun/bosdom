import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/conversation.dart';

class ChatTosNotAcceptedException implements Exception {
  const ChatTosNotAcceptedException();
}

class ChatRestrictedException implements Exception {
  const ChatRestrictedException(this.message, this.restrictedUntil);

  final String message;
  final DateTime? restrictedUntil;
}

class ChatSendException implements Exception {
  const ChatSendException(this.message);

  final String message;
}

abstract final class ChatService {
  static const _timeout = ApiConfig.requestTimeout;

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static String get _currentUserId {
    final id = Supabase.instance.client.auth.currentUser?.id;
    if (id == null) {
      throw Exception('Not signed in');
    }
    return id;
  }

  /// Every conversation the current account is in, whether they're the
  /// buyer side (shopping around other stores) or the seller side (a
  /// customer messaging their shop). The UI splits these by `isSeller` into
  /// separate buyer and seller inboxes (see ChatScreen.sellerMode).
  static Future<List<Conversation>> fetchConversations() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversations: ${response.body}');
    }

    final currentUserId = _currentUserId;
    final body = jsonDecode(response.body) as List;
    return body
        .cast<Map<String, dynamic>>()
        .map(
          (json) =>
              Conversation.fromSummaryJson(json, currentUserId: currentUserId),
        )
        .toList();
  }

  static Future<Conversation> startConversation({
    required String counterpartId,
    String? listingId,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'counterpart_id': counterpartId,
            if (listingId != null) 'listing_id': listingId,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to start conversation: ${response.body}');
    }

    return Conversation.fromSummaryJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      currentUserId: _currentUserId,
    );
  }

  /// Get-or-create the current account's thread with the BosDom Support team.
  static Future<Conversation> openSupportConversation() async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/chat/support'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to open support chat: ${response.body}');
    }

    return Conversation.fromSummaryJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      currentUserId: _currentUserId,
    );
  }

  static Future<Conversation> fetchConversation(String id) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$id'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load conversation: ${response.body}');
    }

    return Conversation.fromDetailJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      currentUserId: _currentUserId,
    );
  }

  static Future<void> markRead(String id) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$id/read'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to mark conversation read: ${response.body}');
    }
  }

  static Future<ChatMessage> sendMessage(String id, String text) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$id/messages'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return ChatMessage.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
        currentUserId: _currentUserId,
      );
    }

    dynamic detail;
    try {
      detail = (jsonDecode(response.body) as Map<String, dynamic>)['detail'];
    } catch (_) {
      detail = null;
    }

    if (response.statusCode == 403 && detail is Map<String, dynamic>) {
      final code = detail['code'] as String?;
      if (code == 'tos_not_accepted') {
        throw const ChatTosNotAcceptedException();
      }
      if (code == 'chat_restricted') {
        final until = detail['restricted_until'] as String?;
        throw ChatRestrictedException(
          detail['message'] as String? ??
              'Temporarily restricted from sending messages',
          until != null ? DateTime.parse(until) : null,
        );
      }
    }

    throw ChatSendException(
      detail is String ? detail : 'Failed to send message',
    );
  }

  static Future<ChatMessage> sendImage(String id, File file) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(
              '${ApiConfig.baseUrl}/chat/conversations/$id/messages/image',
            ),
          )
          ..headers.addAll(_authHeaders)
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path,
              // image_picker is called with imageQuality set (see _attachPhoto
              // in chat_detail_screen.dart), which always re-encodes to JPEG.
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ChatMessage.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
        currentUserId: _currentUserId,
      );
    }

    dynamic detail;
    try {
      detail = (jsonDecode(response.body) as Map<String, dynamic>)['detail'];
    } catch (_) {
      detail = null;
    }

    if (response.statusCode == 403 && detail is Map<String, dynamic>) {
      final code = detail['code'] as String?;
      if (code == 'tos_not_accepted') {
        throw const ChatTosNotAcceptedException();
      }
      if (code == 'chat_restricted') {
        final until = detail['restricted_until'] as String?;
        throw ChatRestrictedException(
          detail['message'] as String? ??
              'Temporarily restricted from sending messages',
          until != null ? DateTime.parse(until) : null,
        );
      }
    }

    throw ChatSendException(detail is String ? detail : 'Failed to send photo');
  }

  static Future<bool> fetchTosAccepted() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/chat/tos/status'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load chat policy status: ${response.body}');
    }

    return (jsonDecode(response.body) as Map<String, dynamic>)['accepted']
        as bool;
  }

  static Future<void> acceptTos() async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/chat/tos/accept'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to accept chat policy: ${response.body}');
    }
  }
}
