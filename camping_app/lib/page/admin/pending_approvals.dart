import 'package:flutter/material.dart';

class PendingApprovalsScreen extends StatelessWidget {
  final VoidCallback onBack;
  const PendingApprovalsScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pendingUsers = _getPendingUsers();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending Approvals', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('${pendingUsers.length} users waiting', style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 12)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: pendingUsers.length,
        itemBuilder: (context, index) => _buildUserCard(pendingUsers[index]),
      ),
    );
  }

  List<Map<String, dynamic>> _getPendingUsers() {
    return [
      {'id': 1, 'name': 'Sarah Wilson', 'email': 'sarah.wilson@example.com', 'phone': '+62 812-3456-7890', 'location': 'Jakarta', 'registered': '2025-12-18 10:30'},
      {'id': 2, 'name': 'Mike Johnson', 'email': 'mike.johnson@example.com', 'phone': '+62 813-4567-8901', 'location': 'Bandung', 'registered': '2025-12-18 09:15'},
      {'id': 3, 'name': 'Emma Davis', 'email': 'emma.davis@example.com', 'phone': '+62 814-5678-9012', 'location': 'Surabaya', 'registered': '2025-12-17 16:45'},
    ];
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Registered: ${user['registered']}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, user['email']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, user['phone']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, user['location']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel, size: 20),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)))),
      ],
    );
  }
}