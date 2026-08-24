import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

class PaymentIntentResult {
  const PaymentIntentResult({
    required this.clientSecret,
    required this.publishableKey,
  });

  final String clientSecret;
  final String publishableKey;
}

abstract final class PaymentService {
  static Future<PaymentIntentResult> createPaymentIntent({
    required double amount,
    String currency = 'usd',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payments/intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'currency': currency}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return PaymentIntentResult(
      clientSecret: body['client_secret'] as String,
      publishableKey: body['publishable_key'] as String,
    );
  }
}
