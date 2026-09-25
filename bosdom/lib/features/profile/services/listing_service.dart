import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/seller_listing.dart';

/// A named color option a seller offers for a listing, e.g. `('Navy', '#243B55')`.
class ListingColorOption {
  const ListingColorOption({required this.name, required this.hex});

  final String name;
  final String hex;

  Map<String, String> toJson() => {'name': name, 'hex': hex};
}

abstract final class ListingService {
  static const _timeout = ApiConfig.requestTimeout;

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<void> create({
    required String productName,
    required String category,
    required double price,
    required int moqQty,
    required int stockQty,
    required String description,
    required bool sampleTestingEnabled,
    double? samplePrice,
    List<String> sizes = const [],
    List<ListingColorOption> colors = const [],
    String weight = '',
    String origin = '',
    String grade = '',
    String packaging = '',
    required List<File> photos,
  }) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('${ApiConfig.baseUrl}/listings/me'),
          )
          ..headers.addAll(_authHeaders)
          ..fields['product_name'] = productName
          ..fields['category'] = category
          ..fields['price'] = price.toString()
          ..fields['moq_qty'] = moqQty.toString()
          ..fields['stock_qty'] = stockQty.toString()
          ..fields['description'] = description
          ..fields['sample_testing_enabled'] = sampleTestingEnabled.toString()
          ..fields['sizes'] = sizes.join(',')
          ..fields['colors'] = jsonEncode([
            for (final color in colors) color.toJson(),
          ])
          ..fields['weight'] = weight
          ..fields['origin'] = origin
          ..fields['grade'] = grade
          ..fields['packaging'] = packaging;

    if (sampleTestingEnabled && samplePrice != null) {
      request.fields['sample_price'] = samplePrice.toString();
    }

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

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to create listing: ${response.body}');
    }
  }

  static Future<List<SellerListing>> listMine() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/listings/me'),
          headers: _authHeaders,
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load inventory: ${response.body}');
    }
    final body = jsonDecode(response.body) as List;
    return body
        .cast<Map<String, dynamic>>()
        .map(SellerListing.fromJson)
        .toList();
  }

  static Future<SellerListing> setActive(String listingId, bool active) async {
    final response = await http
        .patch(
          Uri.parse('${ApiConfig.baseUrl}/listings/me/$listingId/active'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'active': active}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to update listing: ${response.body}');
    }
    return SellerListing.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
