import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

abstract final class ReportService {
  static Future<void> reportOrder({
    required String orderId,
    required String reason,
    String note = '',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/report'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'reason': reason, 'note': note}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to report order: ${response.body}');
    }
  }
}
