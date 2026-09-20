import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the admin's bearer token in memory + `localStorage` (via
/// shared_preferences' web implementation) so a page refresh doesn't force
/// a re-login. Single instance ([adminSession]), listened to with
/// [ListenableBuilder] instead of pulling in a state-management package for
/// what is otherwise a very small app.
class AdminSession extends ChangeNotifier {
  static const _tokenKey = 'bosdom_admin_token';

  String? _token;
  bool _restored = false;

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get restored => _restored;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _restored = true;
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
}

final adminSession = AdminSession();
