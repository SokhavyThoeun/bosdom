/// Dev backend addresses for the networks this app gets tested on.
///
/// `scripts/dev.sh` detects the Mac's current LAN IP and passes it in via
/// `--dart-define=API_BASE_URL=...`, so switching networks needs no edit here.
/// The constants below are only the fallback for a bare `flutter run`: flip
/// [_useUniversity] and hot-restart when you switch networks.
abstract final class ApiConfig {
  static const _homeIp = 'http://192.168.18.89:8000';
  static const _universityIp = 'http://172.21.1.205:8000';

  static const _useUniversity = false;

  static const _fallbackUrl = _useUniversity ? _universityIp : _homeIp;

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _fallbackUrl,
  );

  /// Resolves an avatar path returned by the backend into a loadable URL.
  ///
  /// Self-uploaded avatars come back as relative paths (e.g.
  /// `/media/avatars/xxx.jpg`) and need [baseUrl] prefixed. Avatars seeded
  /// from Google sign-in are already absolute URLs (e.g.
  /// `https://lh3.googleusercontent.com/...`) and must be used as-is.
  static String? resolveAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }
    return '$baseUrl$avatarUrl';
  }
}
