import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/ads_consent.dart';

abstract final class AdsConsentService {
  static Future<AdsConsent> fetch(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ads-consent/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load ads consent: ${response.body}');
    }

    return AdsConsent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<AdsConsent> save(String userId, AdsConsent consent) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ads-consent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, ...consent.toJson()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save ads consent: ${response.body}');
    }

    return AdsConsent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
