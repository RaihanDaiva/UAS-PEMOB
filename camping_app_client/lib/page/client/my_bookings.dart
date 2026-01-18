import 'package:flutter/material.dart';
import '../../services/api_admin_services.dart';

class MyBookings extends StatefulWidget {
  final VoidCallback onBack;

  const MyBookings({Key? key, required this.onBack}) : super(key: key);

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  String activeTab = 'upcoming';
  List<Map<String, dynamic>> bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final data = await apiService.getMyBookings();
      setState(() {
        bookings = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Filter: Upcoming - status 'pending' OR 'confirmed'
  List<Map<String, dynamic>> get upcomingBookings {
    return bookings.where((b) {
      final status = b['booking_status'];
      return status == 'confirmed' || status == 'pending';
    }).toList();
  }

  // Filter: Past - status 'completed' ONLY
  List<Map<String, dynamic>> get pastBookings {
    return bookings.where((b) {
      final status = b['booking_status'];
      return status == 'completed';
    }).toList();
  }

  // Filter: Cancelled - status 'cancelled' ONLY
  List<Map<String, dynamic>> get cancelledBookings {
    return bookings.where((b) {
      final status = b['booking_status'];
      return status == 'cancelled';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Display bookings based on active tab
    List<Map<String, dynamic>> displayBookings;
    if (activeTab == 'upcoming') {
      displayBookings = upcomingBookings;
    } else if (activeTab == 'past') {
      displayBookings = pastBookings;
    } else {
      displayBookings = cancelledBookings;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        onPressed: widget.onBack,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs - NOW 3 TABS
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Upcoming', 'upcoming')),
                  Expanded(child: _buildTabButton('Past', 'past')),
                  Expanded(child: _buildTabButton('Cancelled', 'cancelled')),
                ],
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchBookings,
                    child: displayBookings.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: displayBookings.length,
                            itemBuilder: (context, index) {
                              final booking = displayBookings[index];
                              return _buildBookingCard(booking);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isActive = activeTab == value;
    return GestureDetector(
      onTap: () => setState(() => activeTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFF10B981)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['booking_status'] ?? 'pending';

    // Get campsite data from flat structure
    final campsiteName = booking['campsite_name'] ?? 'Unknown Campsite';
    final campsiteLocation = booking['campsite_location'] ?? '-';
    final campsiteImage = booking['campsite_image_url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: campsiteImage != null && campsiteImage != ''
                      ? Image.network(
                          campsiteImage,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 96,
                              height: 96,
                              color: Colors.grey[300],
                              child: const Icon(Icons.cabin_outlined),
                            );
                          },
                        )
                      : Container(
                          width: 96,
                          height: 96,
                          color: Colors.grey[300],
                          child: const Icon(Icons.cabin_outlined),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              campsiteName ?? 'Unknown Campsite',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              campsiteLocation ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BOOKING CODE SECTION - TAMBAH DI SINI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 4),
                Text(
                  booking['booking_code'] ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Booking Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-in',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                booking['check_in_date'] ?? '-',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-out',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                booking['check_out_date'] ?? '-',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${booking['num_tents'] ?? booking['number_of_tents'] ?? 0} Tents • ${booking['num_people'] ?? booking['number_of_guests'] ?? 0} Guests',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      'Rp ${_formatPrice(booking['total_price']?.toDouble() ?? 0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActionButton(status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;

    switch (status) {
      case 'confirmed':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        borderColor = const Color(0xFF6EE7B7);
        label = 'Confirmed';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        borderColor = const Color(0xFFFCD34D);
        label = 'Pending';
        break;
      case 'completed':
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF4F46E5);
        borderColor = const Color(0xFFC7D2FE);
        label = 'Completed';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        borderColor = const Color(0xFFFCA5A5);
        label = 'Cancelled';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        borderColor = const Color(0xFFD1D5DB);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(String status) {
    Widget button;

    switch (status) {
      case 'confirmed':
      case 'pending':
        button = ElevatedButton(
          onPressed: () {
            // TODO: Navigate to booking detail
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('View Details - Coming soon')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text('View Details', style: TextStyle(fontSize: 14)),
        );
        break;
      case 'completed':
        button = ElevatedButton(
          onPressed: () {
            // TODO: Navigate to review page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Write Review - Coming soon')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text('Write Review', style: TextStyle(fontSize: 14)),
        );
        break;
      case 'cancelled':
        button = OutlinedButton(
          onPressed: () {
            // TODO: Navigate to booking detail
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('View Details - Coming soon')),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6B7280),
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          child: const Text('View Details', style: TextStyle(fontSize: 14)),
        );
        break;
      default:
        button = const SizedBox.shrink();
    }

    return button;
  }

  Widget _buildEmptyState() {
    String emptyMessage;
    IconData emptyIcon;

    if (activeTab == 'upcoming') {
      emptyMessage = 'No upcoming bookings';
      emptyIcon = Icons.calendar_today_outlined;
    } else if (activeTab == 'past') {
      emptyMessage = 'No past bookings';
      emptyIcon = Icons.history;
    } else {
      emptyMessage = 'No cancelled bookings';
      emptyIcon = Icons.cancel_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(emptyIcon, size: 40, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
