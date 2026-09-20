/// Dev backend addresses for the two networks this app gets tested on.
/// Flip [_useUniversity] and hot-reload when you switch networks — no
/// in-app UI, no persisted state.
abstract final class ApiConfig {
  static const _homeIp = 'http://192.168.18.45:8000';
  static const _universityIp = 'http://192.168.1.63:8000';

  static const _useUniversity = false;

  static const baseUrl = _useUniversity ? _universityIp : _homeIp;

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
