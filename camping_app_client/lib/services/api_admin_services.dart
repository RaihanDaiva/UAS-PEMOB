// lib/services/api_service.dart
import 'dart:convert';
import 'package:camping_app_client/models/campsite.dart';
import 'package:camping_app_client/models/user.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // IMPORTANT: Change this to your Flask server IP address
  // For Android Emulator: use 10.0.2.2 instead of localhost
  // For Physical Device: use your computer's IP (e.g., 192.168.1.100)
  // static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Alternative base URLs (uncomment the one you need):
  static const String baseUrl =
      'http://192.168.100.6:5000/api'; // Physical device
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS Simulator

  String? _token;

  // Set token after login
  void setToken(String token) {
    _token = token;
  }

  // Get token
  String? getToken() {
    return _token;
  }

  // Clear token on logout
  void clearToken() {
    _token = null;
  }

  // Get headers with authentication
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ============================================
  // AUTHENTICATION ENDPOINTS
  // ============================================

  /// Login user (both admin and client)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token
        _token = data['access_token'];
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register(Map<String, String> userData) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final url = Uri.parse('$baseUrl/auth/profile');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Profile error: $e');
    }
  }

  // ============================================
  // ADMIN - DASHBOARD STATS
  // ============================================

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final url = Uri.parse('$baseUrl/admin/dashboard/stats');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['stats'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get stats');
      }
    } catch (e) {
      throw Exception('Dashboard stats error: $e');
    }
  }

  // ============================================
  // ADMIN - USER MANAGEMENT
  // ============================================

  /// Get pending user approvals
  Future<List<User>> getPendingUsers() async {
    try {
      final url = Uri.parse('$baseUrl/admin/users/pending');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);
      print("data TYPE:");
      print(data.runtimeType);

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['pending_users'] as List)
            .map((e) => User.fromJson(e))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to get pending users');
      }
    } catch (e) {
      print('Pending users error: $e');
      throw Exception('Pending users error: $e');
    }
  }

  Future<int> getTotalPendingUsers() async {
    try {
      final url = Uri.parse('$baseUrl/admin/users/pending');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['pending_users'] as List).length;
      } else {
        throw Exception(data['message'] ?? 'Failed to get pending users');
      }
    } catch (e) {
      throw Exception('Get pending users error: $e');
    }
  }

  /// Approve or reject user
  Future<Map<String, dynamic>> approveRejectUser(
    int userId,
    String action, { // 'approve' or 'reject'
    String? notes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/admin/users/$userId/approval');

      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'action': action, if (notes != null) 'notes': notes}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to $action user');
      }
    } catch (e) {
      throw Exception('Approval error: $e');
    }
  }

  /// Get all users (admin only)
  Future<List<dynamic>> getAllUsers() async {
    try {
      final url = Uri.parse('$baseUrl/admin/users');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['users'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get users');
      }
    } catch (e) {
      throw Exception('Get users error: $e');
    }
  }

  /// Get total users (admin only)
  Future<int> getTotalUsers() async {
    try {
      final url = Uri.parse('$baseUrl/admin/users/total');
      final response = await http.get(url, headers: _getHeaders());
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['total_users'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get total users');
      }
    } catch (e) {
      throw Exception('Get total users error: $e');
    }
  }

  /// Get detail of a user (admin only)
  Future<Map<String, dynamic>> getUserDetail(int userId) async {
    final url = Uri.parse('$baseUrl/admin/users/$userId');
    final response = await http.get(url, headers: _getHeaders());
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['user'];
    } else {
      throw Exception(data['message'] ?? 'Failed to get user detail');
    }
  }

  // ============================================
  // ADMIN - BOOKING MANAGEMENT
  // ============================================

  /// Get all bookings (admin view)
  Future<List<dynamic>> getAllBookings({
    String? status,
    String? dateFrom,
  }) async {
    try {
      var url = '$baseUrl/bookings/bookings-list';
      final queryParams = <String, String>{};

      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) queryParams['date_from'] = dateFrom;

      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final response = await http.get(Uri.parse(url), headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['bookings'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get bookings');
      }
    } catch (e) {
      throw Exception('Get bookings error: $e');
    }
  }

  /// Get total bookings (admin)
  Future<int> getTotalBookings() async {
    try {
      final url = Uri.parse('$baseUrl/admin/bookings/total');
      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['total_bookings'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get total bookings');
      }
    } catch (e) {
      throw Exception('Get total bookings error: $e');
    }
  }

  /// Get today's bookings (admin)
  Future<int> getTodayBookings() async {
    try {
      final url = Uri.parse('$baseUrl/admin/bookings/today');
      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['total_today_bookings'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get today bookings');
      }
    } catch (e) {
      throw Exception('Get today bookings error: $e');
    }
  }

  /// Get booking detail by ID
  Future<Map<String, dynamic>> getBookingDetail(int bookingId) async {
    try {
      final url = '$baseUrl/admin/bookings/$bookingId';

      final response = await http.get(Uri.parse(url), headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['booking']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get booking detail');
      }
    } catch (e) {
      throw Exception('Get booking detail error: $e');
    }
  }

  /// Update booking status
  Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status, // 'pending', 'confirmed', 'cancelled', 'completed'
  ) async {
    try {
      final url = Uri.parse('$baseUrl/admin/bookings/$bookingId/status');

      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update booking status');
      }
    } catch (e) {
      throw Exception('Update booking error: $e');
    }
  }

  // ============================================
  // CAMPSITES
  // ============================================

  /// Get all campsites
  Future<List<Campsite>> getCampsites() async {
    final url = Uri.parse('$baseUrl/campsites');

    final response = await http.get(url, headers: _getHeaders());

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return (data['campsites'] as List)
          .map((json) => Campsite.fromJson(json))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to get campsites');
    }
  }

  /// Get total campsites (admin only)
  Future<int> getTotalCampsites() async {
    try {
      final url = Uri.parse('$baseUrl/admin/campsites/total');
      final response = await http.get(url, headers: _getHeaders());
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['total_campsites'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get total campsites');
      }
    } catch (e) {
      throw Exception('Get total campsites error: $e');
    }
  }

  /// Get campsite details
  Future<Map<String, dynamic>> getCampsiteDetails(int campsiteId) async {
    try {
      final url = Uri.parse('$baseUrl/campsites/$campsiteId');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['campsite'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get campsite details');
      }
    } catch (e) {
      throw Exception('Get campsite details error: $e');
    }
  }

  /// Create new campsite (admin only)
  Future<Map<String, dynamic>> createCampsite(
    Map<String, dynamic> campsiteData,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/admin/campsites');

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(campsiteData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create campsite');
      }
    } catch (e) {
      throw Exception('Create campsite error: $e');
    }
  }

  /// Update campsite (admin only)
  Future<Map<String, dynamic>> updateCampsite(
    int campsiteId,
    Map<String, dynamic> campsiteData,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/admin/campsites/$campsiteId');

      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(campsiteData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update campsite');
      }
    } catch (e) {
      throw Exception('Update campsite error: $e');
    }
  }

  /// Delete campsite (admin only)
  Future<Map<String, dynamic>> deleteCampsite(int campsiteId) async {
    try {
      final url = Uri.parse('$baseUrl/admin/campsites/$campsiteId');

      final response = await http.delete(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete campsite');
      }
    } catch (e) {
      throw Exception('Delete campsite error: $e');
    }
  }

  // ============================================
  // CLIENT - BOOKINGS
  // ============================================

  /// Create booking (client)
  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/bookings');

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(bookingData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Create booking error: $e');
    }
  }

  /// Get my bookings (client)
  Future<List<dynamic>> getMyBookings() async {
    try {
      final url = Uri.parse('$baseUrl/bookings/my-bookings');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['bookings'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get bookings');
      }
    } catch (e) {
      throw Exception('Get my bookings error: $e');
    }
  }

  /// Get booking details
  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    try {
      final url = Uri.parse('$baseUrl/bookings/$bookingId');

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['booking'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get booking details');
      }
    } catch (e) {
      throw Exception('Get booking details error: $e');
    }
  }

  // ============================================
  // WEATHER
  // ============================================

  /// Get weather forecast
  Future<Map<String, dynamic>> getWeatherForecast(
    int campsiteId, {
    int days = 7,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/weather/forecast?campsite_id=$campsiteId&days=$days',
      );

      final response = await http.get(url, headers: _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get weather forecast');
      }
    } catch (e) {
      throw Exception('Weather forecast error: $e');
    }
  }
}

// Singleton instance
final apiService = ApiService();
