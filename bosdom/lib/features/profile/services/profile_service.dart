import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/user_profile.dart';

abstract final class ProfileService {
  static const _timeout = Duration(seconds: 8);

  static Future<UserProfile> fetch(String userId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/profile/$userId'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load profile: ${response.body}');
    }

    return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<UserProfile> save(String userId, UserProfile profile) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/profile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId, ...profile.toJson()}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to save profile: ${response.body}');
    }

    return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<UserProfile> uploadAvatar(String userId, File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/profile/$userId/avatar'),
    )..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload avatar: ${response.body}');
    }

    return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
