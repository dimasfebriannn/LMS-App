import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Email dan password wajib diisi!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        // Sesuaikan IP Hotspot kamu di sini
        Uri.parse('http://10.114.52.108:8000/api/login'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar(data['message'], Colors.green);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage(userData: data['user'])),
        );
      } else {
        _showSnackBar(data['message'] ?? "Login Gagal", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Gagal terhubung ke server!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan Animasi Gradasi & Curve Modern
            Stack(
              children: [
                Container(
                  height: 320,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Efek melayang pada Icon
                        TweenAnimationBuilder(
                          duration: const Duration(seconds: 2),
                          tween: Tween<double>(begin: 0, end: 10),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, value),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.auto_stories_rounded, size: 70, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "LMS Mobile",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          "Dimas Febrian Project",
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Form Login dengan Animasi Staggered
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      Text(
                        "Selamat Datang!",
                        style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      const Text("Silahkan login untuk melanjutkan proses belajar.", style: TextStyle(color: Colors.grey, fontSize: 15)),
                      const SizedBox(height: 35),
                      
                      _buildLabel("Email Mahasiswa"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        hint: "nama@mhs.ac.id",
                        icon: Icons.alternate_email_rounded,
                      ),
                      
                      const SizedBox(height: 20),
                      _buildLabel("Password"),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "••••••••",
                        icon: Icons.lock_person_rounded,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Lupa Password?", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Tombol Login dengan Animasi
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : Text("MASUK SEKARANG", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF475569)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !(isPasswordVisible ?? false),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(isPasswordVisible! ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey, size: 20),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}