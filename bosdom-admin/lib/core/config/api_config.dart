/// Deployed builds get the backend URL at build time
/// (`--dart-define=API_BASE_URL=https://...`, see vercel.json).
///
/// Without it (local dev), the backend is assumed to run on the host the page
/// was loaded from (`uv run uvicorn ... --port 8000`). That's
/// network-independent — no LAN IP to flip when moving between home and
/// university, which used to cause silent login timeouts.
abstract final class ApiConfig {
  /// How long a request may take before giving up. Generous because the
  /// free Render instance sleeps when idle and takes up to a minute to wake.
  static const requestTimeout = Duration(seconds: 60);
  static const _port = 8000;

  static const _deployedUrl = String.fromEnvironment('API_BASE_URL');

  static final String baseUrl =
      _deployedUrl.isNotEmpty ? _deployedUrl : 'http://${_host()}:$_port';

  /// Turns a backend-relative media path (`/media/...`) into a full URL.
  static String mediaUrl(String path) =>
      path.startsWith('http') ? path : '$baseUrl$path';

  static String _host() {
    final host = Uri.base.host;
    return host.isEmpty ? 'localhost' : host;
  }
}
