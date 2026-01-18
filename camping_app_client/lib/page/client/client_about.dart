import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final VoidCallback onBack;
  const AboutScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // --- HEADER ---
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
                        onPressed: onBack,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'About',
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

          // --- CONTENT (Scrollable) ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Logo & Versi
                  const Icon(Icons.park, size: 80, color: Color(0xFF10B981)),
                  const SizedBox(height: 16),
                  const Text(
                    'CampEase',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- 1. DESKRIPSI APLIKASI ---
                  _buildSectionTitle('Deskripsi Aplikasi'),
                  const SizedBox(height: 12),
                  const Text(
                    'CampEase adalah aplikasi smart camping booking yang memudahkan pengguna untuk mencari, memesan, dan mengelola lokasi perkemahan dengan mudah. Aplikasi ini dirancang untuk memberikan pengalaman reservasi yang mulus bagi para pecinta alam.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
                  ),

                  const SizedBox(height: 32),

                  // --- 2. DEVELOPER (NAMA & NPM) ---
                  _buildSectionTitle('Tim Pengembang'),
                  const SizedBox(height: 12),

                  // LIST ANGGOTA
                  // Ganti 'assets/images/nama_file.jpg' dengan path gambar asli Anda
                  // Jika imagePath dikosongkan (null), akan tampil icon default.
                  
                  _buildDeveloperCard(
                    'Raihan Daiva', 
                    'NRP: 152023033',
                    imagePath: 'assets/images/raihan.jpg', 
                  ),
                  _buildDeveloperCard(
                    'Muhammad Hasby A.S', 
                    'NRP: 152023072',
                    imagePath: 'assets/images/hasby.jpg',
                  ),
                  _buildDeveloperCard(
                    'Firman Fawnia Fauzan', 
                    'NRP: 152023034',
                    imagePath: 'assets/images/firman.jpg',
                  ),
                  _buildDeveloperCard(
                    'Naufal Febrian', 
                    'NRP: 152023010',
                    imagePath: 'assets/images/naufal.jpg',
                  ),

                  const SizedBox(height: 24),

                  // Copyright
                  const Text(
                    '© 2026 CampEase Team',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Judul Section
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  // Helper untuk Kartu Nama Anggota (DIPERBARUI)
  // Menambahkan parameter opsional {String? imagePath}
  Widget _buildDeveloperCard(String name, String npm, {String? imagePath}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // BAGIAN FOTO PROFIL
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(24),
              // Jika imagePath ada, tampilkan gambar. Jika tidak, null.
              image: imagePath != null
                  ? DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            // Jika imagePath tidak ada (null), tampilkan Icon Person sebagai gantinya
            child: imagePath == null
                ? const Icon(
                    Icons.person,
                    color: Color(0xFF10B981),
                  )
                : null,
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  npm,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}