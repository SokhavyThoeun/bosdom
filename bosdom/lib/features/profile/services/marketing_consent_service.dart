import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/marketing_consent.dart';

abstract final class MarketingConsentService {
  static Future<MarketingConsent> fetch(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/marketing-consent/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load marketing consent: ${response.body}');
    }

    return MarketingConsent.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<MarketingConsent> save(
    String userId,
    MarketingConsent consent,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/marketing-consent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'marketing_emails': consent.marketingEmails,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save marketing consent: ${response.body}');
    }

    return MarketingConsent.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
