import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/sample_order.dart';

abstract final class SampleOrderService {
  static const _timeout = Duration(seconds: 8);

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

  static Future<SampleOrder> requestSample(String listingId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/sample-orders'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'listing_id': listingId}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return SampleOrder.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    final detail =
        (jsonDecode(response.body) as Map<String, dynamic>)['detail'];

    if (response.statusCode == 409 && detail is Map<String, dynamic>) {
      final eligibleAt = detail['eligible_at'] as String?;
      throw SampleCooldownException(
        detail['message'] as String? ?? 'Sample cooldown active',
        eligibleAt != null ? DateTime.parse(eligibleAt) : null,
      );
    }

    throw SampleOrderException(
      detail is String ? detail : 'Failed to request sample',
    );
  }
}
