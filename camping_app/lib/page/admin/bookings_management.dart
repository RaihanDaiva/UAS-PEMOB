import 'package:flutter/material.dart';
import '../../services/api_admin_services.dart';
import '../admin/booking_detail.dart';

class BookingsManagementScreen extends StatefulWidget {
  final VoidCallback onBack;
  const BookingsManagementScreen({Key? key, required this.onBack})
    : super(key: key);

  @override
  State<BookingsManagementScreen> createState() =>
      _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  String searchQuery = '';
  String filterStatus = 'all';

  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  // Daftar status yang diizinkan oleh Backend
  final List<String> _allowedStatuses = [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);

    try {
      final data = await apiService.getAllBookings(
        status: filterStatus == 'all' ? null : filterStatus,
      );

      setState(() {
        _bookings = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => _loading = false);
    }
  }

  // --- FUNGSI UPDATE STATUS ---
  Future<void> _showUpdateStatusDialog(
    int bookingId,
    String currentStatus,
  ) async {
    String? selectedStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Update Booking Status'),
          children: _allowedStatuses.map((status) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, status);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      status == currentStatus
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: status == currentStatus
                          ? const Color(0xFF2563EB)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(status), // Preview badge
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );

    if (selectedStatus != null && selectedStatus != currentStatus) {
      // Panggil API
      try {
        // Tampilkan loading indicator sementara
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Updating status...')));

        final success = await apiService.updateBookingStatus(
          bookingId,
          selectedStatus,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh list
          _fetchBookings();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _filteredBookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header with Search (SAMA SEPERTI KODE ANDA)
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
                            '${_bookings.length} total bookings',
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

          const SizedBox(height: 16),

          // Filter Tabs (Bisa di-uncomment jika ingin digunakan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', 'confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Checked In', 'checked_in'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filteredBookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) =>
                        _buildBookingCard(filteredBookings[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isActive = filterStatus == value;
    return GestureDetector(
      onTap: () {
        if (filterStatus == value) return;
        setState(() => filterStatus = value);
        _fetchBookings();
      },
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          '${booking['booking_code'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _truncateWithEllipsis(
                            20,
                            booking['campsite_name']?.toString() ?? '-',
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // --- TOMBOL EDIT STATUS DISINI ---
                    // --- GANTI BAGIAN DROPDOWN DENGAN INI ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(
                          booking['booking_status'],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              _allowedStatuses.contains(
                                booking['booking_status'],
                              )
                              ? booking['booking_status']
                              : null,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: _getStatusTextColor(
                              booking['booking_status'],
                            ),
                            size: 18,
                          ),
                          isDense: true,
                          elevation: 2,
                          dropdownColor: Colors.white,

                          // 1. BAGIAN INI MENGATUR TAMPILAN SAAT TOMBOL TERTUTUP (TETAP BERWARNA)
                          selectedItemBuilder: (BuildContext context) {
                            return _allowedStatuses.map<Widget>((String value) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  value
                                      .split('_')
                                      .map(
                                        (word) =>
                                            word[0].toUpperCase() +
                                            word.substring(1),
                                      )
                                      .join(' '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    // Tetap menggunakan warna dinamis sesuai status
                                    color: _getStatusTextColor(value),
                                  ),
                                ),
                              );
                            }).toList();
                          },

                          // 2. BAGIAN INI MENGATUR TAMPILAN LIST MENU SAAT DIBUKA (WARNA HITAM)
                          items: _allowedStatuses.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value
                                    .split('_')
                                    .map(
                                      (word) =>
                                          word[0].toUpperCase() +
                                          word.substring(1),
                                    )
                                    .join(' '),
                                style: const TextStyle(
                                  color: Colors
                                      .black87, // Warna Hitam saat dropdown dibuka
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),

                          onChanged: (String? newValue) async {
                            if (newValue != null &&
                                newValue != booking['booking_status']) {
                              await _updateStatusDirectly(
                                booking['id'],
                                newValue,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  '${booking['check_in_date']} → ${booking['check_out_date']}',
                ),
              ],
            ),
          ),

          // Detail bawah
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
                          '${booking['num_tents'] ?? 0} Tents',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${booking['num_people'] ?? 0} Guests',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Rp ${_formatPrice((booking['total_price'] ?? 0).toInt())}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingDetailScreen(bookingId: booking['id']),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF6FF),
                        foregroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                      ),
                      child: const Text('View Details'),
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

  String _truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
      case 'completed':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        label = 'Completed';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFEAB308);
        label = 'Pending';
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

  // Fungsi baru untuk menangani update langsung dari Dropdown
  Future<void> _updateStatusDirectly(int bookingId, String newStatus) async {
    try {
      // Tampilkan loading kecil atau snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updating status...'),
          duration: Duration(milliseconds: 500),
        ),
      );

      final success = await apiService.updateBookingStatus(
        bookingId,
        newStatus,
      );

      if (success) {
        // Refresh data setelah sukses
        _fetchBookings();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Helper Warna Background
  Color _getStatusBackgroundColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'confirmed':
        return const Color(0xFFDCFCE7);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      case 'completed':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  // Helper Warna Teks & Icon
  Color _getStatusTextColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFEAB308);
      case 'confirmed':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'completed':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    var result = List<Map<String, dynamic>>.from(_bookings);

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((b) {
        return b['booking_code'].toString().toLowerCase().contains(q) ||
            b['campsite_name'].toString().toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}
