import 'package:flutter/material.dart';
import '../../services/api_admin_services.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? booking;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await apiService.getBookingDetail(widget.bookingId);
      setState(() {
        booking = data;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'completed':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'completed':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Booking Detail'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : booking == null
              ? const Center(child: Text('Booking not found'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: const Color(0xFFF9FAFB),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon and booking code
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.event_note,
                                      size: 40,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    booking!['booking_code'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    booking!['campsite_name'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Status badges
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      // Container(
                                      //   padding: const EdgeInsets.symmetric(
                                      //     horizontal: 12,
                                      //     vertical: 6,
                                      //   ),
                                      //   decoration: BoxDecoration(
                                      //     color: _getStatusColor(
                                      //       booking!['booking_status'] ?? '',
                                      //     ),
                                      //     borderRadius: BorderRadius.circular(12),
                                      //   ),
                                      //   child: Text(
                                      //     booking!['booking_status'] ?? 'N/A',
                                      //     style: TextStyle(
                                      //       fontSize: 12,
                                      //       color: _getStatusTextColor(
                                      //         booking!['booking_status'] ?? '',
                                      //       ),
                                      //       fontWeight: FontWeight.w500,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Booking details
                            _detailRow(
                              'Check In',
                              booking!['check_in_date'] ?? 'N/A',
                            ),
                            _detailRow(
                              'Check Out',
                              booking!['check_out_date'] ?? 'N/A',
                            ),
                            _detailRow(
                              'Total Nights',
                              booking!['total_nights']?.toString() ?? '0',
                            ),
                            _detailRow(
                              'Guests',
                              booking!['num_people']?.toString() ?? '0',
                            ),
                            _detailRow(
                              'Tents',
                              booking!['num_tents']?.toString() ?? '0',
                            ),

                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Payment details
                            _detailRow(
                              'Price / Night',
                              'Rp ${booking!['price_per_night'] ?? '0'}',
                            ),
                            _detailRow(
                              'Subtotal',
                              'Rp ${booking!['subtotal'] ?? '0'}',
                            ),
                            _detailRow(
                              'Tax',
                              'Rp ${booking!['tax_amount'] ?? '0'}',
                            ),
                            _detailRow(
                              'Total',
                              'Rp ${booking!['total_price'] ?? '0'}',
                              isBold: true,
                            ),

                            // Special requests if available
                            if (booking!['special_requests'] != null &&
                                booking!['special_requests'].toString().isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Text(
                                'Special Requests',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                booking!['special_requests'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}