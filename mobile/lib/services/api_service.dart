import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/models/biomarker_data.dart';
import 'package:mobile/models/firebase_config_response.dart';
import 'package:mobile/models/health_metrics.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/services/api_config.dart';

class ApiService {
  ApiService._();

  static const Duration _timeout = Duration(seconds: 30);

  static Future<String> _apiRoot() async {
    final base = await ApiConfig.getBaseUrl();
    return '$base/api';
  }

  static Map<String, String> _jsonHeaders({String? bearer}) {
    return {
      'Content-Type': 'application/json',
      if (bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
    };
  }

  static String _errorMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final message = data['error'] ?? data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}
    return fallback;
  }

  static Future<FirebaseConfigResponse> getFirebaseConfig() async {
    final root = await _apiRoot();
    final response = await http.get(Uri.parse('$root/auth/firebase-config')).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Firebase config failed'));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return FirebaseConfigResponse.fromJson(data);
  }

  static Future<String> resolveIdentifier(String identifier) async {
    final root = await _apiRoot();
    final response = await http
        .post(
          Uri.parse('$root/auth/firebase-resolve-identifier'),
          headers: _jsonHeaders(),
          body: jsonEncode({'identifier': identifier}),
        )
        .timeout(_timeout);
    if (response.statusCode == 404) {
      throw Exception('User not found');
    }
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Resolve failed'));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['email'] as String? ?? '';
  }

  static Future<void> firebaseRegisterProfile({
    required String idToken,
    required String username,
  }) async {
    final root = await _apiRoot();
    final response = await http
        .post(
          Uri.parse('$root/auth/firebase-register-profile'),
          headers: _jsonHeaders(),
          body: jsonEncode({'idToken': idToken, 'username': username}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Profile save failed'));
    }
  }

  static Future<(String token, UserProfile user)> loginWithFirebaseIdToken(
    String idToken,
  ) async {
    final root = await _apiRoot();
    final response = await http
        .post(
          Uri.parse('$root/auth/login-firebase'),
          headers: _jsonHeaders(),
          body: jsonEncode({'idToken': idToken}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Login failed'));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String? ?? '';
    final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    return (token, user);
  }

  static Future<UserProfile> getMe(String token) async {
    final root = await _apiRoot();
    final response = await http
        .get(
          Uri.parse('$root/auth/me'),
          headers: _jsonHeaders(bearer: token),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Session invalid'));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  static Future<Map<String, dynamic>> getHealth() async {
    final root = await _apiRoot();
    final response = await http.get(Uri.parse('$root/health')).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Health check failed'));
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<BiomarkerHistoryRow>> getHistory({
    required String userId,
    String? token,
  }) async {
    final root = await _apiRoot();
    final uri = Uri.parse('$root/data/history').replace(queryParameters: {'userId': userId});
    final response = await http
        .get(uri, headers: token != null ? _jsonHeaders(bearer: token) : _jsonHeaders())
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'History failed'));
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => BiomarkerHistoryRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> getRecommend({
    required String userId,
    String? token,
  }) async {
    final root = await _apiRoot();
    final uri = Uri.parse('$root/ai/recommend').replace(queryParameters: {'userId': userId});
    final response = await http
        .get(uri, headers: token != null ? _jsonHeaders(bearer: token) : _jsonHeaders())
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Recommend failed'));
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSummaryDaily({
    required String userId,
    String? token,
  }) async {
    final root = await _apiRoot();
    final uri = Uri.parse('$root/summary/daily').replace(queryParameters: {'userId': userId});
    final response = await http
        .get(uri, headers: token != null ? _jsonHeaders(bearer: token) : _jsonHeaders())
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Summary failed'));
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> postDataStore({
    required String userId,
    String? token,
  }) async {
    final root = await _apiRoot();
    final response = await http
        .post(
          Uri.parse('$root/data/store'),
          headers: token != null ? _jsonHeaders(bearer: token) : _jsonHeaders(),
          body: jsonEncode({'userId': userId}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Store failed'));
    }
  }

  /// Returns saved [waterIntake] from the response body.
  static Future<double> postWater({
    required String userId,
    required double waterIntake,
    String? token,
  }) async {
    final root = await _apiRoot();
    final response = await http
        .post(
          Uri.parse('$root/data/water'),
          headers: token != null ? _jsonHeaders(bearer: token) : _jsonHeaders(),
          body: jsonEncode({'userId': userId, 'waterIntake': waterIntake}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Water sync failed'));
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['waterIntake'] as num?)?.toDouble() ?? waterIntake;
  }

  /// `POST /api/data/custom` — same as web `quickAddMetric` / `saveMetricValue`.
  /// Returns the saved biomarker row from the response `data` field.
  static Future<BiomarkerData> postCustomMetrics({
    required String userId,
    required Map<String, dynamic> fields,
    String? token,
  }) async {
    final root = await _apiRoot();
    final body = <String, dynamic>{'userId': userId, ...fields};
    final response = await http
        .post(
          Uri.parse('$root/data/custom'),
          headers: token != null ? _jsonHeaders(bearer: token) : _jsonHeaders(),
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Save metric failed'));
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = decoded['data'];
    if (raw is! Map<String, dynamic>) {
      throw Exception('Invalid save response');
    }
    return BiomarkerData.fromJson(raw);
  }

  static Future<String> sendChat({
    required String userId,
    required String message,
    String? token,
  }) async {
    final root = await _apiRoot();
    final response = await http
        .post(
          Uri.parse('$root/ai/chat'),
          headers: token != null ? _jsonHeaders(bearer: token) : _jsonHeaders(),
          body: jsonEncode({'message': message, 'userId': userId}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Chat failed'));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['response'] as String? ?? '';
  }

  /// Latest metrics + insight text from recommend API.
  static Future<HealthMetrics> loadDashboardMetrics({
    required String userId,
    required String token,
  }) async {
    final history = await getHistory(userId: userId, token: token);
    final recommend = await getRecommend(userId: userId, token: token);
    final insight = (recommend['recommendation'] as String?)?.trim() ?? '';
    if (history.isEmpty) {
      return HealthMetrics.fromBiomarker(
        const BiomarkerData(
          steps: 0,
          heartRate: 0,
          bloodPressure: '--',
          weight: 0,
          calorieIntake: 0,
          waterIntake: 0,
          sleepHours: 0,
        ),
        insight: insight.isEmpty ? 'No biomarker data yet. Generate or add metrics.' : insight,
      );
    }
    final latest = history.first.data;
    return HealthMetrics.fromBiomarker(
      latest,
      insight: insight.isEmpty ? 'Stay consistent with your daily habits.' : insight,
    );
  }
}
