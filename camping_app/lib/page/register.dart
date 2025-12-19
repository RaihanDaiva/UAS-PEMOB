import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const Color primaryGreen = Color(0xFF0BA84A);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;


  Future<void> register() async {
    setState(() => loading = true);

    final response = await AuthService.register(
      name: nameController.text,
      phone: phoneController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() => loading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, tunggu approval admin')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registrasi gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            _logo(),

            _card(
              title: 'Create Account',
              children: [
                _inputField('Full Name', nameController),
                _inputField('Phone Number', phoneController),
                _inputField('Email', emailController),
                _inputField('Password', passwordController, obscure: true),
                const SizedBox(height: 16),
                _warningBox(),
                const SizedBox(height: 24),
                _submitButton('Sign Up', register),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Sign In'),
                ),
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
      Text(
        'Smart Camping Booking',
        style: TextStyle(color: Colors.white70),
      ),
      SizedBox(height: 40),
    ],
  );
}

Widget _card({
  required String title,
  required List<Widget> children,
}) {
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );
}

Widget _submitButton(String text, VoidCallback onPressed,
    {bool loading = false}) {
  return ElevatedButton(
    onPressed: loading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: loading
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
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


Widget _inputField(String label, TextEditingController controller,
    {bool obscure = false}) {
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

