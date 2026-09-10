import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/order.dart';

abstract final class OrderService {
  static const _timeout = Duration(seconds: 10);

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<List<Order>> fetchMyOrders() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/orders/me'), headers: _authHeaders)
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load orders: ${response.body}');
    }

    final body = jsonDecode(response.body) as List;
    return body
        .cast<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }

  static Future<Order> fetchOrder(String orderId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load order: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
