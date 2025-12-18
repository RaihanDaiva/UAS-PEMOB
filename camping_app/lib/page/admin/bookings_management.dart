import 'package:flutter/material.dart';

class BookingsManagementScreen extends StatefulWidget {
  final VoidCallback onBack;
  const BookingsManagementScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<BookingsManagementScreen> createState() => _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  String searchQuery = '';
  String filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final bookings = _getFilteredBookings();

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
                            'Bookings Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_getAllBookings().length} total bookings',
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
                    hintText: 'Search by ID, user, or campsite...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', 'confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: bookings.length,
              itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isActive = filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking ID: ${booking['id']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking['campsite'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusBadge(booking['status']),
                  ],
                ),
                const SizedBox(height: 12),
                // User Info
                _buildInfoRow(Icons.person_outline, booking['userName']),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, booking['location']),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  '${booking['checkIn']} → ${booking['checkOut']}',
                ),
              ],
            ),
          ),

          // Details Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${booking['tents']} Tents',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${booking['guests']} Guests',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    _buildPaymentBadge(booking['paymentStatus']),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Color(0xFF16A34A),
                          size: 20,
                        ),
                        Text(
                          'Rp ${_formatPrice(booking['total'])}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF6FF),
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 14),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'confirmed':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'Confirmed';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFEAB308);
        label = 'Pending';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
      case 'completed':
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        label = 'Completed';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'paid':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'Paid';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFEAB308);
        label = 'Pending';
        break;
      case 'refunded':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        label = 'Refunded';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  List<Map<String, dynamic>> _getAllBookings() {
    return [
      {
        'id': 'BK001',
        'campsite': 'Green Valley Camp',
        'location': 'Bandung',
        'userName': 'John Doe',
        'checkIn': '2025-12-20',
        'checkOut': '2025-12-22',
        'tents': 2,
        'guests': 4,
        'total': 330000,
        'status': 'confirmed',
        'paymentStatus': 'paid',
      },
      {
        'id': 'BK002',
        'campsite': 'Mountain Peak Resort',
        'location': 'Bogor',
        'userName': 'Jane Smith',
        'checkIn': '2025-12-22',
        'checkOut': '2025-12-24',
        'tents': 1,
        'guests': 2,
        'total': 440000,
        'status': 'pending',
        'paymentStatus': 'pending',
      },
      {
        'id': 'BK003',
        'campsite': 'Lakeside Paradise',
        'location': 'Cianjur',
        'userName': 'Bob Wilson',
        'checkIn': '2025-12-19',
        'checkOut': '2025-12-21',
        'tents': 3,
        'guests': 6,
        'total': 1155000,
        'status': 'confirmed',
        'paymentStatus': 'paid',
      },
      {
        'id': 'BK004',
        'campsite': 'Sunset Beach Camp',
        'location': 'Pelabuhan Ratu',
        'userName': 'Alice Brown',
        'checkIn': '2025-12-21',
        'checkOut': '2025-12-23',
        'tents': 2,
        'guests': 4,
        'total': 396000,
        'status': 'confirmed',
        'paymentStatus': 'paid',
      },
      {
        'id': 'BK005',
        'campsite': 'Green Valley Camp',
        'location': 'Bandung',
        'userName': 'Charlie Davis',
        'checkIn': '2025-12-23',
        'checkOut': '2025-12-25',
        'tents': 1,
        'guests': 2,
        'total': 165000,
        'status': 'cancelled',
        'paymentStatus': 'refunded',
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredBookings() {
    var bookings = _getAllBookings();

    // Filter by status
    if (filterStatus != 'all') {
      bookings = bookings.where((b) => b['status'] == filterStatus).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      bookings = bookings.where((b) {
        final id = b['id'].toString().toLowerCase();
        final user = b['userName'].toString().toLowerCase();
        final campsite = b['campsite'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return id.contains(query) || user.contains(query) || campsite.contains(query);
      }).toList();
    }

    return bookings;
  }
}