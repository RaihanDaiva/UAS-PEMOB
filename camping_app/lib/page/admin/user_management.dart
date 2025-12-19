import 'package:flutter/material.dart';
import '../../services/api_admin_services.dart';
import '../admin/user_detail.dart';

class UserManagementScreen extends StatefulWidget {
  final VoidCallback onBack;
  const UserManagementScreen({Key? key, required this.onBack})
    : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String searchQuery = '';
  String filterStatus = 'all';
  List<Map<String, dynamic>> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final data = await apiService.getAllUsers();
      setState(() {
        users = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint('Fetch users error: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      body: Column(
        children: [
          // Header with Search
          Container(
            color: const Color(0xFF2563EB),
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: widget.onBack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${users.length} total users',
                            style: const TextStyle(
                              color: Color(0xFFDBEAFE),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', users.length),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active', _getActiveUsers().length),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Inactive',
                  'inactive',
                  _getInactiveUsers().length,
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: users.length,
              itemBuilder: (context, index) => _buildUserCard(users[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isActive = filterStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => filterStatus = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? null
                : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isActive = user['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 24),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isActive ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user['email'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildInfoChip(
                      isActive ? 'Active' : 'Inactive',
                      isActive ? Colors.green : Colors.red,
                    ),
                    _buildInfoChip(
                      '${user['bookings']} bookings',
                      const Color(0xFF6B7280),
                    ),
                    _buildInfoChip(
                      'Joined ${user['joined']}',
                      const Color(0xFF6B7280),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserDetailScreen(
                                userId: user['id'],
                                onBack: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                        ),
                        child: Text(
                          isActive ? 'Deactivate' : 'Activate',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  // List<Map<String, dynamic>> users {
  //   return [
  //     {
  //       'id': 1,
  //       'name': 'John Doe',
  //       'email': 'john.doe@example.com',
  //       'status': 'active',
  //       'bookings': 12,
  //       'joined': '2024-01-15',
  //     },
  //     {
  //       'id': 2,
  //       'name': 'Jane Smith',
  //       'email': 'jane.smith@example.com',
  //       'status': 'active',
  //       'bookings': 8,
  //       'joined': '2024-02-20',
  //     },
  //     {
  //       'id': 3,
  //       'name': 'Bob Wilson',
  //       'email': 'bob.wilson@example.com',
  //       'status': 'active',
  //       'bookings': 15,
  //       'joined': '2024-01-10',
  //     },
  //     {
  //       'id': 4,
  //       'name': 'Alice Brown',
  //       'email': 'alice.brown@example.com',
  //       'status': 'inactive',
  //       'bookings': 3,
  //       'joined': '2024-11-05',
  //     },
  //     {
  //       'id': 5,
  //       'name': 'Charlie Davis',
  //       'email': 'charlie.davis@example.com',
  //       'status': 'active',
  //       'bookings': 20,
  //       'joined': '2023-12-01',
  //     },
  //     {
  //       'id': 6,
  //       'name': 'Diana Miller',
  //       'email': 'diana.miller@example.com',
  //       'status': 'active',
  //       'bookings': 6,
  //       'joined': '2024-03-15',
  //     },
  //   ];
  // }

  List<Map<String, dynamic>> _getActiveUsers() {
    return users.where((u) => u['status'] == 'active').toList();
  }

  List<Map<String, dynamic>> _getInactiveUsers() {
    return users.where((u) => u['status'] == 'inactive').toList();
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    var result = users;

    if (filterStatus != 'all') {
      result = result.where((u) => u['status'] == filterStatus).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((u) {
        return u['name'].toLowerCase().contains(q) ||
            u['email'].toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}
