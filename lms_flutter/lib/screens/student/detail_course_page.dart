import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DetailCoursePage extends StatelessWidget {
  final Map<String, dynamic> course;

  // Kunci satu warna utama agar seragam dengan Dashboard
  final Color primaryColor = const Color(0xFF2563EB);

  const DetailCoursePage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // HEADER MODERN (SLIVER)
          SliverAppBar(
            expandedHeight: 300.0, // Sedikit lebih tinggi agar lega
            floating: false,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: primaryColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background Utama dengan Gradasi Dalam
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E3A8A), // Biru Gelap
                          primaryColor, // Biru Utama
                          primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // 2. Decorative Watermark Icon (Membuat Header tidak kaku)
                  Positioned(
                    right: -30,
                    top: 40,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 200,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // 3. Konten Utama Header
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ring Animasi di sekitar Icon
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Badge Status (Glassmorphism)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Mata Kuliah Utama",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Bottom White Curve (Mempercantik pertemuan header dan body)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 30,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BODY CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Dosen
                  Text(
                    course['title'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        course['lecturer'],
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info Cards (SKS & Progress)
                  Row(
                    children: [
                      _buildSmallStatCard("3 SKS", Icons.history_edu_rounded),
                      const SizedBox(width: 12),
                      _buildSmallStatCard("Semester 4", Icons.school_rounded),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle("Tentang Mata Kuliah"),
                  const SizedBox(height: 12),
                  Text(
                    "Mata kuliah ini dirancang untuk memberikan pemahaman mendalam mengenai konsep dan implementasi di bidang ${course['title']}. Pastikan kamu aktif mengikuti setiap modul.",
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle("Kurikulum Modul"),
                  const SizedBox(height: 16),

                  // LIST MODUL
                  AnimationLimiter(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 500),
                        childAnimationBuilder: (widget) => FadeInAnimation(
                          child: SlideAnimation(
                            verticalOffset: 20,
                            child: widget,
                          ),
                        ),
                        children: [
                          _buildModuleItem(
                            "01",
                            "Pengenalan Materi",
                            "Video Tutorial • 15 m",
                            true,
                          ),
                          _buildModuleItem(
                            "02",
                            "Instalasi & Persiapan",
                            "E-Book • 12 MB",
                            false,
                          ),
                          _buildModuleItem(
                            "03",
                            "Studi Kasus Dasar",
                            "Video Tutorial • 20 m",
                            false,
                          ),
                          _buildModuleItem(
                            "04",
                            "Tugas Mandiri 1",
                            "Assignment • 3 Hari",
                            false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      // ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: primaryColor,
        elevation: 4,
        label: Text(
          "MULAI BELAJAR",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildSmallStatCard(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem(String step, String title, String sub, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.green.withOpacity(0.1)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 20,
                    )
                  : Text(
                      step,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_circle_outline_rounded,
            color: isDone ? Colors.green : Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
