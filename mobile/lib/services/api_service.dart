import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/models/health_metrics.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/services/api_config.dart';
import 'package:mobile/services/database_service.dart';

class ApiService {
  ApiService._();

  static const Duration _timeout = Duration(seconds: 30);

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

  static Future<(String token, UserProfile user)> login({
    required String email,
    required String password,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Login failed'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String? ?? '';
    final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    await DatabaseService.saveToken(token);
    await DatabaseService.saveUser(user);
    return (token, user);
  }

  static Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception(_errorMessage(response, 'Registration failed'));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      await DatabaseService.saveUser(user);
      return user;
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}');
      } else if (e.toString().contains('SocketException')) {
        final baseUrl = await ApiConfig.getBaseUrl();
        throw Exception('Cannot connect to $baseUrl. Check if PC and Phone are on the same Wi-Fi.');
      }
      rethrow;
    }
  }

  static Future<HealthMetrics> fetchMetrics({required String token}) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final response = await http
        .get(
          Uri.parse('$baseUrl/metrics'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Metrics failed'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final metrics = HealthMetrics.fromJson(data);
    await DatabaseService.saveMetrics(metrics);
    return metrics;
  }

  static Future<String> sendChat({
    required String token,
    required String message,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final response = await http
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'message': message}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response, 'Chat failed'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['reply'] as String? ?? 'I am here to help.';
  }
}
