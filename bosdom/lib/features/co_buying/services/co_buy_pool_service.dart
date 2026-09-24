import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show Color;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../../../shared/models/variant_option.dart';
import '../models/co_buy_session.dart';

/// Thrown by [CoBuyPoolService.joinPool] when the request is rejected —
/// quantity below the deal's minimum (400) or above what's left before the
/// target is reached (409). Callers should catch this and surface
/// [message] rather than letting it propagate.
class CoBuyJoinException implements Exception {
  const CoBuyJoinException(this.message);

  final String message;
}

String _colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

abstract final class CoBuyPoolService {
  static const _timeout = Duration(seconds: 15);

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<List<CoBuySession>> fetchPools() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/co-buy/pools'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load co-buy deals: ${response.body}');
    }
    final body = jsonDecode(response.body) as List;
    return body
        .cast<Map<String, dynamic>>()
        .map(CoBuySession.fromJson)
        .toList();
  }

  static Future<List<CoBuySession>> fetchMyPools() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/co-buy/pools/me'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load your co-buy deals: ${response.body}');
    }
    final body = jsonDecode(response.body) as List;
    return body
        .cast<Map<String, dynamic>>()
        .map(CoBuySession.fromJson)
        .toList();
  }

  static Future<CoBuySession> fetchPool(String id) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/co-buy/pools/$id'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    if (response.statusCode == 404) {
      throw Exception('Co-buy deal not found');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load co-buy deal: ${response.body}');
    }
    return CoBuySession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<http.MultipartRequest> _poolFormRequest(
    String method,
    Uri uri, {
    required String productName,
    required String category,
    required String description,
    required double price,
    required double originalPrice,
    required int targetQty,
    required String unitLabel,
    required String perUnitLabel,
    required int minOrderQty,
    required String timeLeft,
    required bool autoRenew,
    required List<String> sizes,
    required List<ProductColorOption> colorOptions,
    required String weight,
    required String origin,
    required String grade,
    required String packaging,
    required List<File> photos,
  }) async {
    final request = http.MultipartRequest(method, uri)
      ..headers.addAll(_authHeaders)
      ..fields['product_name'] = productName
      ..fields['category'] = category
      ..fields['description'] = description
      ..fields['price'] = price.toString()
      ..fields['original_price'] = originalPrice.toString()
      ..fields['target_qty'] = targetQty.toString()
      ..fields['unit_label'] = unitLabel
      ..fields['per_unit_label'] = perUnitLabel
      ..fields['min_order_qty'] = minOrderQty.toString()
      ..fields['time_left'] = timeLeft
      ..fields['auto_renew'] = autoRenew.toString()
      ..fields['sizes'] = sizes.join(',')
      ..fields['colors'] = jsonEncode([
        for (final color in colorOptions)
          {'name': color.name, 'hex': _colorToHex(color.color)},
      ])
      ..fields['weight'] = weight
      ..fields['origin'] = origin
      ..fields['grade'] = grade
      ..fields['packaging'] = packaging;

    for (final photo in photos) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photos',
          photo.path,
          // The picker always re-encodes to JPEG, but the temp file path it
          // hands back doesn't reliably carry a recognizable extension —
          // without an explicit content type, mime-sniffing can fall back
          // to application/octet-stream and the backend rejects the upload.
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    return request;
  }

  static Future<CoBuySession> createPool({
    required String productName,
    String category = '',
    required String description,
    required double price,
    required double originalPrice,
    required int targetQty,
    required String unitLabel,
    required String perUnitLabel,
    required int minOrderQty,
    required String timeLeft,
    required bool autoRenew,
    List<String> sizes = const [],
    List<ProductColorOption> colorOptions = const [],
    String weight = '',
    String origin = '',
    String grade = '',
    String packaging = '',
    List<File> photos = const [],
  }) async {
    final request = await _poolFormRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/co-buy/pools'),
      productName: productName,
      category: category,
      description: description,
      price: price,
      originalPrice: originalPrice,
      targetQty: targetQty,
      unitLabel: unitLabel,
      perUnitLabel: perUnitLabel,
      minOrderQty: minOrderQty,
      timeLeft: timeLeft,
      autoRenew: autoRenew,
      sizes: sizes,
      colorOptions: colorOptions,
      weight: weight,
      origin: origin,
      grade: grade,
      packaging: packaging,
      photos: photos,
    );
    final response = await http.Response.fromStream(
      await request.send().timeout(_timeout),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create co-buy deal: ${response.body}');
    }
    return CoBuySession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<CoBuySession> updatePool(
    String id, {
    required String productName,
    String category = '',
    required String description,
    required double price,
    required double originalPrice,
    required int targetQty,
    required String unitLabel,
    required String perUnitLabel,
    required int minOrderQty,
    required String timeLeft,
    required bool autoRenew,
    List<String> sizes = const [],
    List<ProductColorOption> colorOptions = const [],
    String weight = '',
    String origin = '',
    String grade = '',
    String packaging = '',
    List<File> photos = const [],
  }) async {
    final request = await _poolFormRequest(
      'PUT',
      Uri.parse('${ApiConfig.baseUrl}/co-buy/pools/me/$id'),
      productName: productName,
      category: category,
      description: description,
      price: price,
      originalPrice: originalPrice,
      targetQty: targetQty,
      unitLabel: unitLabel,
      perUnitLabel: perUnitLabel,
      minOrderQty: minOrderQty,
      timeLeft: timeLeft,
      autoRenew: autoRenew,
      sizes: sizes,
      colorOptions: colorOptions,
      weight: weight,
      origin: origin,
      grade: grade,
      packaging: packaging,
      photos: photos,
    );
    final response = await http.Response.fromStream(
      await request.send().timeout(_timeout),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update co-buy deal: ${response.body}');
    }
    return CoBuySession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<void> deletePool(String id) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}/co-buy/pools/me/$id'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete co-buy deal: ${response.body}');
    }
  }

  static Future<CoBuySession> joinPool(
    String id, {
    required int quantity,
    String? size,
    ProductColorOption? color,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/co-buy/pools/$id/join'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'quantity': quantity,
            'size': size,
            'color_name': color?.name,
            'color_hex': color != null ? _colorToHex(color.color) : null,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return CoBuySession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 400 || response.statusCode == 409) {
      final detail =
          (jsonDecode(response.body) as Map<String, dynamic>)['detail'];
      throw CoBuyJoinException(
        detail is String ? detail : 'Unable to join this co-buy deal',
      );
    }
    throw Exception('Failed to join co-buy deal: ${response.body}');
  }

  static Future<CoBuySession> leavePool(String id) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}/co-buy/pools/$id/join'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      return CoBuySession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 404 || response.statusCode == 409) {
      final detail =
          (jsonDecode(response.body) as Map<String, dynamic>)['detail'];
      throw CoBuyJoinException(
        detail is String ? detail : 'Unable to leave this co-buy deal',
      );
    }
    throw Exception('Failed to leave co-buy deal: ${response.body}');
  }

  /// Asks an admin to let this (already paid) buyer out of the deal.
  static Future<CoBuySession> requestLeave(String id, String reason) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/co-buy/pools/$id/leave-request'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'reason': reason}),
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      return CoBuySession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 409) {
      final detail =
          (jsonDecode(response.body) as Map<String, dynamic>)['detail'];
      throw CoBuyJoinException(
        detail is String ? detail : 'Unable to send your leave request',
      );
    }
    throw Exception('Failed to request leave: ${response.body}');
  }
}
