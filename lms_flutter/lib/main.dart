import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:lms_flutter/scanner_page.dart'; // Pastikan path file ini benar
import 'dart:convert';
import 'login_page.dart';
import 'detail_course_page.dart';

void main() => runApp(const LmsApp());

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LMS Pro',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DashboardPage({super.key, required this.userData});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color primaryColor = const Color(0xFF2563EB);
  int _selectedIndex = 0;
  List<dynamic> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    const String apiUrl = 'http://10.114.52.108:8000/api/courses';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          courses = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // REVISI: Tab index 2 diganti Placeholder agar tidak bentrok dengan Navigator.push
  List<Widget> _getPages() {
    return [
      _buildHomeContent(), // Index 0
      const Center(child: Text("Halaman Tugas")), // Index 1
      const Scaffold(body: Center(child: CircularProgressIndicator())), // Index 2 (Placeholder)
      _buildProfileContent(), // Index 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _getPages()[_selectedIndex],
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.03),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          if (index == 2) {
            // JIKA KLIK PRESENSI: Buka kamera sebagai Overlay (Navigator.push)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScannerPage(course: courses)),
            ).then((_) {
              // Setelah kembali dari kamera, pastikan index tetap di Home
              setState(() => _selectedIndex = 0);
            });
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        height: 65,
        indicatorColor: primaryColor.withOpacity(0.1),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Tugas'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Presensi'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    String userName = widget.userData['name'] ?? 'Mahasiswa';
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: fetchCourses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(userName),
              _buildStatsCard(),
              _buildSectionTitle("Mata Kuliah Kamu"),
              if (isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (courses.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Belum ada mata kuliah.")))
              else
                _buildCourseList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Halo, Selamat Belajar!", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.search_rounded, color: Colors.grey[800], size: 26)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$name&background=2563EB&color=fff'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainScanButton(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSquareMenu("Riwayat", "Absen", Icons.history_rounded, Colors.orange),
              const SizedBox(width: 12),
              _buildSquareMenu("Rapot", "Mahasiswa", Icons.analytics_rounded, Colors.purple),
              const SizedBox(width: 12),
              _buildSquareMenu("Jadwal", "Kuliah", Icons.calendar_month_rounded, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquareMenu(String line1, String line2, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(line1, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            Text(line2, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScanButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: InkWell(
        onTap: () {
          // Navigasi yang sama dengan Bottom Nav
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScannerPage(course: courses)),
          ).then((_) => setState(() => _selectedIndex = 0));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          child: Row(
            children: [
              const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 30),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Presensi Barcode", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Scan untuk kehadiran hari ini", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.5), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
          Text("Lihat Semua", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    return AnimationLimiter(
      child: SizedBox(
        height: 240,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            var course = courses[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 1000),
              child: FadeInAnimation(
                child: SlideAnimation(
                  horizontalOffset: 100.0,
                  child: _buildHorizontalCard(course, context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(Map<String, dynamic> course, BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailCoursePage(course: course))),
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(right: -20, bottom: -20, child: Icon(Icons.menu_book_rounded, size: 120, color: primaryColor.withOpacity(0.03))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Icon(Icons.menu_book_rounded, color: primaryColor, size: 24),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                        child: const Text("Aktif", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(course['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), height: 1.2)),
                  const SizedBox(height: 6),
                  Text(course['lecturer'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (course['progress'] as num).toDouble(), backgroundColor: Colors.grey[100], color: primaryColor, minHeight: 6))),
                      const SizedBox(width: 12),
                      Text("${((course['progress'] as num) * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${widget.userData['name']}&background=2563EB&color=fff')),
          const SizedBox(height: 20),
          Text(widget.userData['name'] ?? 'User', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false),
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Keluar Akun"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }
}