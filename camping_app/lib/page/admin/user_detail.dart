import 'package:flutter/material.dart';
import '../../services/api_admin_services.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  final VoidCallback onBack;

  const UserDetailScreen({Key? key, required this.userId, required this.onBack})
    : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetail();
  }

  Future<void> fetchUserDetail() async {
    try {
      final data = await apiService.getUserDetail(widget.userId);
      setState(() {
        user = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load user detail: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🔵 BLUE NAVBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text(
          'User Detail',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('User not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 👤 HEADER USER
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: Color(0xFFE5E7EB),
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user!['full_name'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user!['email'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    _buildInfoChip(
                                      user!['role'] ?? '-',
                                      Colors.blue,
                                    ),
                                    _buildInfoChip(
                                      user!['is_active'] == true
                                          ? 'Active'
                                          : 'Inactive',
                                      user!['is_active'] == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    _buildInfoChip(
                                      user!['registration_status'] ?? '-',
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const Divider(),

                      /// 📋 DETAIL INFO
                      _buildDetailRow(
                        'Phone Number',
                        user!['phone_number'] ?? '-',
                      ),
                      _buildDetailRow('Address', user!['address'] ?? '-'),
                      _buildDetailRow(
                        'Joined',
                        user!['created_at']?.substring(0, 10) ?? '-',
                      ),
                      _buildDetailRow(
                        'Total Bookings',
                        user!['total_bookings']?.toString() ?? '0',
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// ==========================
  /// COMPONENTS
  /// ==========================

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
