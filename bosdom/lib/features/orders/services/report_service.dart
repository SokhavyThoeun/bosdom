import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';

abstract final class ReportService {
  /// Buyer reporting a problem: opens a dispute, which freezes the order's
  /// review timer until an admin decides (`POST /orders/{id}/dispute`).
  static Future<void> reportOrder({
    required String orderId,
    required String reason,
    String note = '',
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('Not signed in');
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/dispute'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason, 'note': note}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to report order: ${response.body}');
    }
  }
}
