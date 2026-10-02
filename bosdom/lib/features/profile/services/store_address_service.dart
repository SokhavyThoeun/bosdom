import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/store_address.dart';

/// The seller's store address book, kept on the backend so it survives
/// reinstalls and follows the account across devices. Every mutation
/// returns the full, server-ordered book.
abstract final class StoreAddressService {
  static const _timeout = ApiConfig.requestTimeout;
  static const _path = '/shop/me/addresses';

  static Map<String, String> get _headers {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static List<StoreAddress> _decode(http.Response response, String action) {
    if (response.statusCode != 200) {
      throw Exception('Failed to $action store address: ${response.body}');
    }
    return [
      for (final e in jsonDecode(response.body) as List)
        StoreAddress.fromJson(e as Map<String, dynamic>),
    ];
  }

  /// Also seeds the first address from the shop's registration location
  /// when the seller has never had one.
  static Future<List<StoreAddress>> fetch() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}$_path'), headers: _headers)
        .timeout(_timeout);
    return _decode(response, 'load');
  }

  static Future<List<StoreAddress>> add(StoreAddress address) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$_path'),
          headers: _headers,
          body: jsonEncode(address.toJson()),
        )
        .timeout(_timeout);
    return _decode(response, 'add');
  }

  static Future<List<StoreAddress>> update(StoreAddress address) async {
    final response = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}$_path/${address.id}'),
          headers: _headers,
          body: jsonEncode(address.toJson()),
        )
        .timeout(_timeout);
    return _decode(response, 'update');
  }

  static Future<List<StoreAddress>> delete(String id) async {
    final response = await http
        .delete(Uri.parse('${ApiConfig.baseUrl}$_path/$id'), headers: _headers)
        .timeout(_timeout);
    return _decode(response, 'delete');
  }

  static Future<List<StoreAddress>> setDefault(String id) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$_path/$id/default'),
          headers: _headers,
        )
        .timeout(_timeout);
    return _decode(response, 'update');
  }
}
