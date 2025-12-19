import 'package:flutter/material.dart';
import '../admin_app.dart';
import '../../services/api_admin_services.dart';
import 'dart:async';

// AdminDashboardScreen

class AdminDashboardScreen extends StatefulWidget {
  final Function(AdminScreen) onNavigate;
  const AdminDashboardScreen({Key? key, required this.onNavigate})
    : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalUsers = 0;
  bool loading = true;

  int totalCampsites = 0;
  bool loadingCampsites = true;

  Timer? _refreshTimer; // Tambahkan variabel timer

  @override
  void initState() {
    super.initState();
    fetchAllStats();
    // Set timer untuk auto-refresh setiap 30 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchAllStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Pastikan timer dibersihkan
    super.dispose();
  }

  void fetchAllStats() {
    fetchTotalUsers();
    fetchTotalCampsites();
  }

  Future<void> fetchTotalUsers() async {
    try {
      final count = await apiService.getTotalUsers();
      setState(() {
        totalUsers = count;
        loading = false;
      });
    } catch (e) {
      debugPrint('Fetch total users error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchTotalCampsites() async {
    try {
      final count = await apiService.getTotalCampsites();
      setState(() {
        totalCampsites = count;
        loadingCampsites = false;
      });
    } catch (e) {
      debugPrint('Fetch total campsites error: $e');
      setState(() {
        loadingCampsites = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF9FAFB),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Welcome back, Admin',
                              style: TextStyle(
                                color: Color(0xFFDBEAFE),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            'Pending Approval',
                            '5',
                            Colors.yellow.shade700,
                            Icons.warning_amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStat(
                            "Today's Bookings",
                            '12',
                            Colors.green,
                            Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Stats
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        Icons.people,
                        'Total Users',
                        loading ? '...' : totalUsers.toString(),
                        Colors.green,
                      ),
                      _buildStatCard(
                        Icons.calendar_today,
                        'Total Bookings',
                        '156',
                        Colors.blue,
                      ),
                      _buildStatCard(
                        Icons.forest,
                        'Campsites',
                        loadingCampsites ? '...' : totalCampsites.toString(),
                        Colors.purple,
                      ),
                      _buildStatCard(
                        Icons.attach_money,
                        'Revenue',
                        '45M',
                        Colors.yellow.shade700,
                      ),
                    ],
                  ),
                ),
              ),

              // Management Menu
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text(
                      'Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.how_to_reg,
                      title: 'Pending User Approvals',
                      subtitle: '5 users waiting',
                      color: Colors.yellow.shade700,
                      badge: '5',
                      onTap: () => widget.onNavigate(AdminScreen.approvals),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.people,
                      title: 'User Management',
                      subtitle: 'Manage all users',
                      color: Colors.green,
                      onTap: () => widget.onNavigate(AdminScreen.users),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.calendar_month,
                      title: 'Bookings Management',
                      subtitle: 'View & manage bookings',
                      color: Colors.blue,
                      onTap: () => widget.onNavigate(AdminScreen.bookings),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.forest,
                      title: 'Campsite Management',
                      subtitle: 'Add & edit campsites',
                      color: Colors.purple,
                      onTap: () => widget.onNavigate(AdminScreen.campsites),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 12),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10), // default: 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
