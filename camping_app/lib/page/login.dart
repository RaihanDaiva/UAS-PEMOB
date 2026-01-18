import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/api_admin_services.dart';
import '../page/register.dart';
import 'admin_app.dart';

// COLORS
const Color primaryGreen = Color(0xFF2563EB);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isAdminMode = false;
  bool loading = false;

  final authService = AuthService();

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final data = await authService.login(
        emailController.text,
        passwordController.text,
      );

      
    
      // Ambil data user & role
      final user = data['user'];
      final role = user['role'];
      final status = user['registration_status'];

      // --- PERBAIKAN DI SINI ---
      // Cek jika role adalah client, langsung lempar Exception
      if (role == 'client') {
        // Text ini akan muncul di SnackBar: "Exception: Invalid email or password"
        // Anda bisa mengubah pesannya menjadi "client tidak boleh login di sini" jika mau.
        throw Exception('Invalid email or password'); 
      }
      // -------------------------

      apiService.setToken(data['access_token']);

      if (status != 'approved') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun belum disetujui admin')),
        );
        return;
      }

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminApp()),
        );
      }
      
    } catch (e) {
      // Blok ini akan menangkap Exception di atas dan menampilkannya
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 140),
            _logo(),

            _card(
              title: 'Welcome Back, Admin',
              children: [
                _inputField('Email', emailController),
                const SizedBox(height: 16),
                _inputField('Password', passwordController, obscure: true),
                const SizedBox(height: 24),
                _submitButton('Sign In', login),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _logo() {
  return Column(
    children: const [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: Icon(Icons.park, size: 40, color: primaryGreen),
      ),
      SizedBox(height: 16),
      Text(
        'CampEase',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      Text('Smart Camping Booking', style: TextStyle(color: Colors.white70)),
      SizedBox(height: 40),
    ],
  );
}

Widget _card({required String title, required List<Widget> children}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );
}

Widget _submitButton(
  String text,
  VoidCallback onPressed, {
  bool loading = false,
}) {
  return ElevatedButton(
    onPressed: loading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: loading
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(text, style: const TextStyle(color: Colors.white)),
  );
}

Widget _warningBox() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.yellow.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange),
    ),
    child: const Row(
      children: [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Your account will need admin approval before you can start booking.',
          ),
        ),
      ],
    ),
  );
}

Widget _inputField(
  String label,
  TextEditingController controller, {
  bool obscure = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: 'Enter your ${label.toLowerCase()}',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ],
  );
}

// Singleton instance
final authService = AuthService();
