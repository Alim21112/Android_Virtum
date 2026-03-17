import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves the API base URL so the app works with any IP.
class ApiConfig {
  ApiConfig._();

  static const _keyBaseUrl = 'api_base_url';
  static const String defaultBaseUrl = 'http://10.0.2.2:3000';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_keyBaseUrl);
    if (url != null && url.trim().isNotEmpty) {
      return _normalize(url.trim());
    }
    return defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = url.trim().isEmpty ? defaultBaseUrl : _normalize(url.trim());
    await prefs.setString(_keyBaseUrl, normalized);
  }

  static String _normalize(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'http://$url';
    }
    return url;
  }
}
