import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';

/// The problem a buyer reported on an order, as the seller sees it while an
/// admin runs the case (`DisputeOut`, `routers/disputes.py`).
class OrderDispute {
  const OrderDispute({
    required this.id,
    required this.reason,
    required this.note,
    required this.status,
    this.sellerResponse,
  });

  factory OrderDispute.fromJson(Map<String, dynamic> json) => OrderDispute(
    id: json['id'] as String,
    reason: json['reason'] as String,
    note: json['note'] as String,
    status: json['status'] as String,
    sellerResponse: json['seller_response'] as String?,
  );

  final String id;
  final String reason;
  final String note;

  /// `evidence_window` / `under_review` (reported), `case_open`, `resolved`.
  final String status;
  final String? sellerResponse;

  bool get isCaseOpen => status == 'case_open';
}

abstract final class DisputeService {
  static const _timeout = Duration(seconds: 10);

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('Not signed in');
    return {'Authorization': 'Bearer $token'};
  }

  static Future<OrderDispute?> fetchForOrder(String orderId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/dispute'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Failed to load dispute: ${response.body}');
    }
    return OrderDispute.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<void> sellerReply(String disputeId, String text) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/disputes/$disputeId/seller-reply'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  /// The seller flags a delivery problem, with optional screenshots, so an
  /// admin can look into it and update the buyer. Doesn't change the order's
  /// status or funds.
  static Future<void> reportAsSeller({
    required String orderId,
    required String reason,
    String note = '',
    List<String> photoPaths = const [],
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/seller-report'),
    )..headers.addAll(_authHeaders);
    request.fields['reason'] = reason;
    request.fields['note'] = note;
    for (final path in photoPaths) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photos',
          path,
          // The picker re-encodes to JPEG, but its temp path doesn't reliably
          // carry an image extension — without an explicit content type the
          // backend can reject the upload as "Unsupported image type".
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    final response = await http.Response.fromStream(
      await request.send().timeout(const Duration(seconds: 30)),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
