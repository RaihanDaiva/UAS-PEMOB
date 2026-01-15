import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApiDocumentation extends StatelessWidget {
  final VoidCallback onBack;

  const ApiDocumentation({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: onBack,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'API Documentation',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Backend API Endpoints',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // API List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Authentication APIs
                  _buildApiSection(
                    context,
                    title: 'Authentication',
                    icon: Icons.lock_outline,
                    color: const Color(0xFF3B82F6),
                    endpoints: [
                      ApiEndpoint(
                        method: 'POST',
                        path: '/api/auth/login',
                        description: 'Login user (admin or client)',
                        body:
                            '{"email": "user@example.com", "password": "password"}',
                      ),
                      ApiEndpoint(
                        method: 'POST',
                        path: '/api/auth/register',
                        description: 'Register new client user',
                        body:
                            '{"email": "...", "password": "...", "full_name": "...", "phone_number": "..."}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Campsite APIs
                  _buildApiSection(
                    context,
                    title: 'Campsites',
                    icon: Icons.cabin_outlined,
                    color: const Color(0xFF10B981),
                    endpoints: [
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/campsites',
                        description: 'Get all active campsites',
                        requiresAuth: true,
                      ),
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/campsites/:id',
                        description: 'Get campsite details by ID',
                        requiresAuth: true,
                      ),
                      ApiEndpoint(
                        method: 'POST',
                        path: '/api/admin/campsites',
                        description: 'Create new campsite (admin only)',
                        requiresAuth: true,
                        adminOnly: true,
                      ),
                      ApiEndpoint(
                        method: 'PUT',
                        path: '/api/admin/campsites/:id',
                        description: 'Update campsite (admin only)',
                        requiresAuth: true,
                        adminOnly: true,
                      ),
                      ApiEndpoint(
                        method: 'DELETE',
                        path: '/api/admin/campsites/:id',
                        description: 'Delete campsite (admin only)',
                        requiresAuth: true,
                        adminOnly: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Booking APIs
                  _buildApiSection(
                    context,
                    title: 'Bookings',
                    icon: Icons.calendar_today_outlined,
                    color: const Color(0xFFF59E0B),
                    endpoints: [
                      ApiEndpoint(
                        method: 'POST',
                        path: '/api/bookings',
                        description: 'Create new booking',
                        requiresAuth: true,
                        body:
                            '{"campsite_id": 1, "check_in_date": "2024-12-20", "check_out_date": "2024-12-22", ...}',
                      ),
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/my-bookings',
                        description: 'Get current user bookings',
                        requiresAuth: true,
                      ),
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/bookings/:id',
                        description: 'Get booking details',
                        requiresAuth: true,
                      ),
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/admin/bookings',
                        description: 'Get all bookings (admin only)',
                        requiresAuth: true,
                        adminOnly: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Weather APIs
                  _buildApiSection(
                    context,
                    title: 'Weather',
                    icon: Icons.wb_sunny_outlined,
                    color: const Color(0xFF6366F1),
                    endpoints: [
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/weather/forecast',
                        description: 'Get weather forecast for campsite',
                        requiresAuth: true,
                        queryParams: 'campsite_id=1&days=8',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Management APIs
                  _buildApiSection(
                    context,
                    title: 'User Management',
                    icon: Icons.people_outline,
                    color: const Color(0xFFEC4899),
                    endpoints: [
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/admin/users/pending',
                        description: 'Get pending user registrations',
                        requiresAuth: true,
                        adminOnly: true,
                      ),
                      ApiEndpoint(
                        method: 'PUT',
                        path: '/api/admin/users/:id/approve-reject',
                        description: 'Approve or reject user registration',
                        requiresAuth: true,
                        adminOnly: true,
                        body: '{"action": "approve"}',
                      ),
                      ApiEndpoint(
                        method: 'GET',
                        path: '/api/admin/users',
                        description: 'Get all users (admin only)',
                        requiresAuth: true,
                        adminOnly: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Base URL Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      border: Border.all(color: const Color(0xFF93C5FD)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Base URL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'http://localhost:5000',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E40AF),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'For Android Emulator: http://10.0.2.2:5000',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF1E40AF).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<ApiEndpoint> endpoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...endpoints.map((endpoint) => _buildEndpointCard(context, endpoint)),
      ],
    );
  }

  Widget _buildEndpointCard(BuildContext context, ApiEndpoint endpoint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEndpointDetails(context, endpoint),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMethodBadge(endpoint.method),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        endpoint.path,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (endpoint.adminOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  endpoint.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (endpoint.requiresAuth) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Requires Authentication',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodBadge(String method) {
    Color color;
    switch (method) {
      case 'GET':
        color = const Color(0xFF10B981);
        break;
      case 'POST':
        color = const Color(0xFF3B82F6);
        break;
      case 'PUT':
        color = const Color(0xFFF59E0B);
        break;
      case 'DELETE':
        color = const Color(0xFFDC2626);
        break;
      default:
        color = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        method,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showEndpointDetails(BuildContext context, ApiEndpoint endpoint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMethodBadge(endpoint.method),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    endpoint.path,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: endpoint.path));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Endpoint copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              endpoint.description,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            if (endpoint.queryParams != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Query Parameters',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  endpoint.queryParams!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
            if (endpoint.body != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Request Body',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  endpoint.body!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiEndpoint {
  final String method;
  final String path;
  final String description;
  final bool requiresAuth;
  final bool adminOnly;
  final String? body;
  final String? queryParams;

  ApiEndpoint({
    required this.method,
    required this.path,
    required this.description,
    this.requiresAuth = false,
    this.adminOnly = false,
    this.body,
    this.queryParams,
  });
}
