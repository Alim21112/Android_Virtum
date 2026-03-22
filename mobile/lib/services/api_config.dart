/// API base URL without trailing slash (no `/api` suffix — [ApiService] adds `/api/...`).
class ApiConfig {
  ApiConfig._();

  /// Production Virtum API (Replit deployment).
  static const String defaultBaseUrl = 'https://android-virtum--ayoamooo.replit.app';

  static Future<String> getBaseUrl() async => defaultBaseUrl;
}
