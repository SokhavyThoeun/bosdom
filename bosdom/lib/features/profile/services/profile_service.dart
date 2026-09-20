import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/user_profile.dart';

abstract final class ProfileService {
  static const _timeout = Duration(seconds: 8);

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<UserProfile> fetch() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/profile/me'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load profile: ${response.body}');
    }

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<UserProfile> save(UserProfile profile) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/profile/me'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode(profile.toJson()),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to save profile: ${response.body}');
    }

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Marks the signup wizard as finished. Must only be called from the last
  /// step of each role's flow — see [UserProfile.onboardingComplete].
  static Future<UserProfile> completeOnboarding() async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/profile/me/complete-onboarding'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to complete onboarding: ${response.body}');
    }

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<UserProfile> uploadAvatar(File file) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('${ApiConfig.baseUrl}/profile/me/avatar'),
          )
          ..headers.addAll(_authHeaders)
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path,
              // The picker (see `_pickAvatar` in edit_profile_screen.dart) always
              // re-encodes to JPEG, but the temp file path it hands back doesn't
              // reliably carry a recognizable extension — without an explicit
              // content type, mime-sniffing can fall back to
              // application/octet-stream and the backend rejects the upload.
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload avatar: ${response.body}');
    }

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// [docType] must be one of `national_id`, `passport`, `business_certificate`
  /// (matches the backend's `_KYC_DOC_TYPES`). Uploading `national_id` flips
  /// the returned profile's `verification_status` to `verified` immediately.
  static Future<UserProfile> uploadKycDocument({
    required String docType,
    required File file,
  }) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('${ApiConfig.baseUrl}/profile/me/kyc-documents'),
          )
          ..headers.addAll(_authHeaders)
          ..fields['doc_type'] = docType
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload document: ${response.body}');
    }

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
