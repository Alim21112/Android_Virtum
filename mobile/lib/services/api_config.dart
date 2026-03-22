/// API base URL without trailing slash (no `/api` suffix — [ApiService] adds `/api/...`).
class ApiConfig {
  ApiConfig._();

  /// Production Virtum API (Replit deployment).
  static const String defaultBaseUrl = 'https://android-virtum--2193edkasidma.replit.app';

  static Future<String> getBaseUrl() async => defaultBaseUrl;
}
