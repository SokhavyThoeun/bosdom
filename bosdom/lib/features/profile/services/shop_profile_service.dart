import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/shop_profile.dart';

abstract final class ShopProfileService {
  static const _timeout = Duration(seconds: 8);

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<ShopProfile> fetch() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/shop/me'), headers: _authHeaders)
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load shop profile: ${response.body}');
    }

    return ShopProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Fetches another seller's public shop info (e.g. to show on their
  /// storefront page) — no auth required.
  static Future<ShopProfile> fetchById(String sellerId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/shop/$sellerId'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load shop profile: ${response.body}');
    }

    return ShopProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<ShopProfile> save(ShopProfile shop) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/shop/me'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode(shop.toJson()),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to save shop profile: ${response.body}');
    }

    return ShopProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<ShopProfile> uploadLogo(File file) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('${ApiConfig.baseUrl}/shop/me/logo'),
          )
          ..headers.addAll(_authHeaders)
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path,
              // The picker always re-encodes to JPEG, but the temp file path it
              // hands back doesn't reliably carry a recognizable extension —
              // without an explicit content type, mime-sniffing can fall back
              // to application/octet-stream and the backend rejects the upload.
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload logo: ${response.body}');
    }

    return ShopProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<ShopProfile> uploadStorePhotos(List<File> files) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/shop/me/photos'),
    )..headers.addAll(_authHeaders);
    for (final file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photos',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload store photos: ${response.body}');
    }

    return ShopProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
