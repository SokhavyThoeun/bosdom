import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/sample_order.dart';

abstract final class SampleOrderService {
  static const _timeout = ApiConfig.requestTimeout;

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<SampleEligibility> fetchEligibility() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/sample-orders/me/eligibility'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load sample eligibility: ${response.body}');
    }

    return SampleEligibility.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
