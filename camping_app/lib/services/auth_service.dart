import 'dart:convert';
import 'package:http/http.dart' as http;

// CONFIG
const String baseUrl = 'http://YOUR_SERVER_IP:5000';

class AuthService {
  static Future<http.Response> login({
    required String email,
    required String password,
    required String role,
  }) {
    return http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );
  }

  static Future<http.Response> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );
  }
}
