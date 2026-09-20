import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

abstract final class CartService {
  /// Maps product id -> quantity for every line currently in the cart.
  static Future<Map<String, int>> fetchCart() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/cart'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cart: ${response.body}');
    }

    return _quantitiesFromResponse(response.body);
  }

  /// Adds [quantity] to the line for [itemId], creating it if absent.
  static Future<Map<String, int>> addItem(String itemId, int quantity) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_id': itemId, 'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add cart item: ${response.body}');
    }

    return _quantitiesFromResponse(response.body);
  }

  /// Sets the line for [itemId] to exactly [quantity].
  static Future<Map<String, int>> updateQuantity(
    String itemId,
    int quantity,
  ) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/cart/items/$itemId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item: ${response.body}');
    }

    return _quantitiesFromResponse(response.body);
  }

  static Future<Map<String, int>> removeItem(String itemId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart/items/$itemId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove cart item: ${response.body}');
    }

    return _quantitiesFromResponse(response.body);
  }

  /// Removes several lines at once (e.g. dropping paid-for items after
  /// checkout).
  static Future<Map<String, int>> removeItems(Set<String> itemIds) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart/items/remove-many'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_ids': itemIds.toList()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove cart items: ${response.body}');
    }

    return _quantitiesFromResponse(response.body);
  }

  static Map<String, int> _quantitiesFromResponse(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final lines = (decoded['lines'] as List).cast<Map<String, dynamic>>();
    return {
      for (final line in lines)
        line['item_id'] as String: line['quantity'] as int,
    };
  }
}
