import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';

/// A named color option a seller offers for a listing, e.g. `('Navy', '#243B55')`.
class ListingColorOption {
  const ListingColorOption({required this.name, required this.hex});

  final String name;
  final String hex;

  Map<String, String> toJson() => {'name': name, 'hex': hex};
}

abstract final class ListingService {
  static const _timeout = Duration(seconds: 15);

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
    required List<File> photos,
  }) async {
    final request = http.MultipartRequest(
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
      ]);

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
}
