import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../auth/admin_session.dart';
import '../config/api_config.dart';
import '../models/admin_models.dart';

/// Thrown for any non-2xx admin API response, carrying the backend's own
/// `detail` message (FastAPI's standard error shape) so screens can show it
/// directly instead of a generic "something went wrong".
class AdminApiException implements Exception {
  AdminApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

abstract final class AdminApiClient {
  static const _timeout = Duration(seconds: 10);

  static Map<String, String> get _authHeaders {
    final token = adminSession.token;
    if (token == null) throw AdminApiException(401, 'Not signed in');
    return {'Authorization': 'Bearer $token'};
  }

  static Future<Map<String, dynamic>> _decodeOrThrow(
    http.Response response,
  ) async {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['detail'] != null) {
          detail = decoded['detail'].toString();
        }
      } catch (_) {
        // Body wasn't JSON — fall back to the raw text above.
      }
      throw AdminApiException(response.statusCode, detail);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<String> login(String email, String password) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/admin/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw AdminApiException(
        0,
        'Cannot reach the backend at ${ApiConfig.baseUrl}. '
        'Is uvicorn running on port 8000?',
      );
    }
    final json = await _decodeOrThrow(response);
    return json['access_token'] as String;
  }

  static Future<AdminStats> fetchStats() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/admin/stats'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    return AdminStats.fromJson(await _decodeOrThrow(response));
  }

  static Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _authHeaders)
        .timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await _decodeOrThrow(response);
    }
    final list = jsonDecode(response.body) as List;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<AdminSeller>> fetchSellers() =>
      _getList('/admin/sellers', AdminSeller.fromJson);

  static Future<List<AdminUser>> fetchUsers() =>
      _getList('/admin/users', AdminUser.fromJson);

  static Future<List<AdminListing>> fetchListings() =>
      _getList('/admin/listings', AdminListing.fromJson);

  static Future<List<AdminOrder>> fetchOrders() =>
      _getList('/admin/orders', AdminOrder.fromJson);

  static Future<List<AdminDispute>> fetchDisputes() =>
      _getList('/admin/disputes', AdminDispute.fromJson);

  static Future<List<AdminPayoutRequest>> fetchPayoutRequests() =>
      _getList('/admin/payout-requests', AdminPayoutRequest.fromJson);

  static Future<List<AdminSellerReport>> fetchSellerReports() =>
      _getList('/admin/seller-reports', AdminSellerReport.fromJson);

  static Future<List<AdminSupportConversation>> fetchSupportConversations() =>
      _getList(
        '/admin/support/conversations',
        AdminSupportConversation.fromJson,
      );

  /// Get-or-create the support thread with [userId] so an admin can message
  /// them first; returns the conversation id.
  static Future<String> startSupportConversation(String userId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/admin/support/conversations'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        )
        .timeout(_timeout);
    final json = await _decodeOrThrow(response);
    return json['id'] as String;
  }

  static Future<List<AdminSupportMessage>> fetchSupportMessages(
    String conversationId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '${ApiConfig.baseUrl}/admin/support/conversations/$conversationId',
          ),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    final json = await _decodeOrThrow(response);
    return (json['messages'] as List)
        .map((m) => AdminSupportMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  static Future<void> replyToSupportConversation(
    String conversationId,
    String text,
  ) async {
    final response = await http
        .post(
          Uri.parse(
            '${ApiConfig.baseUrl}/admin/support/conversations/$conversationId/reply',
          ),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        )
        .timeout(_timeout);
    await _decodeOrThrow(response);
  }

  static Future<void> replyToSupportConversationWithImage(
    String conversationId,
    List<int> bytes,
    String filename,
  ) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(
              '${ApiConfig.baseUrl}/admin/support/conversations/$conversationId/reply-image',
            ),
          )
          ..headers.addAll(_authHeaders)
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: filename,
              contentType: _imageMediaType(filename),
            ),
          );
    final response = await http.Response.fromStream(
      await request.send().timeout(_timeout),
    );
    await _decodeOrThrow(response);
  }

  /// The backend validates the part's Content-Type, and multipart bytes
  /// otherwise default to application/octet-stream, so derive it from the name.
  static MediaType _imageMediaType(String filename) {
    switch (filename.split('.').last.toLowerCase()) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  static Future<void> _post(String path) async {
    final response = await http
        .post(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _authHeaders)
        .timeout(_timeout);
    await _decodeOrThrow(response);
  }

  static Future<void> verifyProfile(String id) =>
      _post('/admin/profiles/$id/verify');

  static Future<void> unverifyProfile(String id) =>
      _post('/admin/profiles/$id/unverify');

  static Future<void> rejectProfile(String id) =>
      _post('/admin/profiles/$id/reject');

  static Future<void> suspendProfile(String id) =>
      _post('/admin/profiles/$id/suspend');

  static Future<void> unsuspendProfile(String id) =>
      _post('/admin/profiles/$id/unsuspend');

  static Future<void> takedownListing(String id) =>
      _post('/admin/listings/$id/takedown');

  static Future<void> restoreListing(String id) =>
      _post('/admin/listings/$id/restore');

  static Future<void> resolveSellerReport(String id) =>
      _post('/admin/seller-reports/$id/resolve');

  static Future<void> refundBuyerForSellerReport(
    String id, {
    required bool immediate,
  }) => _postJson('/admin/seller-reports/$id/refund-buyer', {
    'immediate': immediate,
  });

  static Future<List<AdminCoBuyLeave>> fetchCoBuyLeaveRequests() =>
      _getList('/admin/co-buy-leave-requests', AdminCoBuyLeave.fromJson);

  static Future<void> approveCoBuyLeave(String id) =>
      _post('/admin/co-buy-leave-requests/$id/approve');

  static Future<void> rejectCoBuyLeave(String id, String note) =>
      _postJson('/admin/co-buy-leave-requests/$id/reject', {'note': note});

  static Future<void> releasePayout(String orderId) =>
      _post('/admin/payout-requests/$orderId/release');

  static Future<void> openDisputeCase(String id) =>
      _post('/admin/disputes/$id/open-case');

  static Future<void> _postJson(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    await _decodeOrThrow(response);
  }

  static Future<void> recordCourierReply(String id, String text) =>
      _postJson('/admin/disputes/$id/courier-reply', {'text': text});

  /// The admin's decision: [resolution] is `refund` or `release`, [fault] is
  /// who is at fault (`seller`, `courier`, `buyer` or `none`).
  static Future<void> resolveDispute(
    String id,
    String resolution, {
    required String fault,
  }) => _postJson('/admin/disputes/$id/resolve', {
    'resolution': resolution,
    'fault': fault,
  });
}
