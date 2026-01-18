import 'dart:convert';
import 'package:camping_app/services/api_admin_services.dart';
import 'package:http/http.dart' as http;

const String baseUrl =
    // 'http://192.168.1.10:5000'; // Punya Piw
    // 'http://192.168.1.12:5000'; // Punya Raihan
    // 'http://192.168.1.7:5000'; // Punya Hasby, Wi-Fi Hasby
    'http://192.168.100.6:5000'; // Physical device Raihan Wi-Fi Raihan

class AuthService {
  String? _token;

  String? get token => _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      _token = data['access_token']; // 🔥 SIMPAN TOKEN
      apiService.setToken(data['access_token']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
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

  Future<void> logout() async {
    try {
      // Optional: Call logout endpoint if your backend has one
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API error: $e');
    } finally {
      // Clear local token regardless of API response
      _token = null;
      apiService.setToken('');
    }
  }
}
