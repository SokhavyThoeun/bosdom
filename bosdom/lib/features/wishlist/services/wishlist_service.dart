import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

abstract final class WishlistService {
  static Future<Set<String>> fetchWishlistIds() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/wishlist'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load wishlist: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['item_ids'] as List).cast<String>().toSet();
  }

  static Future<bool> toggleWishlist(String itemId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/wishlist/toggle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_id': itemId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle wishlist: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['in_wishlist'] as bool;
  }
}
