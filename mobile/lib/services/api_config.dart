/// API base URL without trailing slash (no `/api` suffix — [ApiService] adds `/api/...`).
class ApiConfig {
  ApiConfig._();

  /// Replace with your deployed backend URL before release (e.g. `https://....replit.dev`).
  static const String defaultBaseUrl = 'https://YOUR_REPLIT_URL.replit.dev';

  static Future<String> getBaseUrl() async => defaultBaseUrl;
}
