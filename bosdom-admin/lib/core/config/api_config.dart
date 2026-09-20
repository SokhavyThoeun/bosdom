/// The admin app is a web app served from the same dev machine that runs
/// `uv run uvicorn ... --port 8000`, so the backend is always on the host the
/// page was loaded from. This is network-independent — no LAN IP to flip when
/// moving between home and university, which used to cause silent login
/// timeouts.
abstract final class ApiConfig {
  static const _port = 8000;

  static final String baseUrl = 'http://${_host()}:$_port';

  /// Turns a backend-relative media path (`/media/...`) into a full URL.
  static String mediaUrl(String path) =>
      path.startsWith('http') ? path : '$baseUrl$path';

  static String _host() {
    final host = Uri.base.host;
    return host.isEmpty ? 'localhost' : host;
  }
}
