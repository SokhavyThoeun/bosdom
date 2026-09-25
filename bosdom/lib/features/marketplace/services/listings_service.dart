import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../../../shared/models/variant_option.dart' show ProductColorOption;

IconData _iconForCategory(String category) {
  return kCategories
      .firstWhere((c) => c.label == category, orElse: () => kCategories.first)
      .icon;
}

/// Falls back to `-` for a blank spec field, matching how the product
/// detail screen renders an unset wholesale spec.
String _specOrDash(Map<String, dynamic> json, String key) {
  final value = json[key] as String;
  return value.isEmpty ? '-' : value;
}

Product _productFromJson(Map<String, dynamic> json) {
  final category = json['category'] as String;
  final price = (json['price'] as num).toDouble();
  final samplePrice = (json['sample_price'] as num?)?.toDouble();
  final photoUrls = (json['photo_urls'] as List).cast<String>();
  final sizes = (json['sizes'] as List).cast<String>();
  final colors = (json['colors'] as List)
      .cast<Map<String, dynamic>>()
      .map(
        (c) => ProductColorOption(
          c['name'] as String,
          Color(int.parse((c['hex'] as String).replaceFirst('#', '0xFF'))),
        ),
      )
      .toList();

  return Product(
    id: json['id'] as String,
    name: json['product_name'] as String,
    price: '\$${price.toStringAsFixed(2)}',
    samplePrice: samplePrice != null
        ? '\$${samplePrice.toStringAsFixed(2)}'
        : null,
    moq: 'MOQ: ${json['moq_qty']} Units',
    moqValue: json['moq_qty'] as int,
    seller: json['seller_name'] as String,
    icon: _iconForCategory(category),
    category: category,
    imageQuery: category,
    photoUrl: photoUrls.isNotEmpty
        ? ApiConfig.resolveAvatarUrl(photoUrls.first)
        : null,
    sellerLogoOverride: ApiConfig.resolveAvatarUrl(
      json['seller_logo_url'] as String?,
    ),
    sellerId: json['seller_id'] as String,
    verified: json['seller_verified'] as bool,
    location: (json['seller_location'] as String).isNotEmpty
        ? json['seller_location'] as String
        : 'Cambodia',
    inStock: (json['stock_qty'] as int) > 0,
    sizes: sizes,
    colorOptions: colors,
    weight: _specOrDash(json, 'weight'),
    origin: _specOrDash(json, 'origin'),
    grade: _specOrDash(json, 'grade'),
    packaging: _specOrDash(json, 'packaging'),
  );
}

abstract final class ListingsService {
  static const _timeout = ApiConfig.requestTimeout;

  static Future<List<Product>> fetchListings({
    String? q,
    String? category,
    String? sellerId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/listings').replace(
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (category != null && category.isNotEmpty) 'category': category,
        if (sellerId != null && sellerId.isNotEmpty) 'seller_id': sellerId,
      },
    );
    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load listings: ${response.body}');
    }
    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>().map(_productFromJson).toList();
  }

  static Future<Product> fetchListing(String id) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/listings/$id'))
        .timeout(_timeout);
    if (response.statusCode == 404) {
      throw Exception('Listing not found');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load listing: ${response.body}');
    }
    return _productFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Resolves [id] to a [Product]: a stringified [kMockProducts] index for
  /// legacy mock ids, otherwise a real backend listing lookup.
  static Future<Product> resolveProduct(String id) async {
    final index = int.tryParse(id);
    if (index != null && index >= 0 && index < kMockProducts.length) {
      return kMockProducts[index];
    }
    return fetchListing(id);
  }
}
