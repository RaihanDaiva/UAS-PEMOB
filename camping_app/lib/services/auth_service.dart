import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.100.6:5000';

class AuthService {
  static Future<http.Response> login({
    required String email,
    required String password,
  }) {
    return http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
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
        'full_name': name,
        'phone_number': phone,
        'email': email,
        'password': password,
      }),
    );
  }
}
