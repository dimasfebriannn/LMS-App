import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:lms_flutter/screens/student/scanner_page.dart';
import 'qr_generator_page.dart';

class SelectCoursePage extends StatefulWidget {
  final String token; // Token untuk otorisasi API
  const SelectCoursePage({super.key, required this.token});

  get userData => null;

  @override
  State<SelectCoursePage> createState() => _SelectCoursePageState();
}

class _SelectCoursePageState extends State<SelectCoursePage> {
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      debugPrint("--- CEK TOKEN ---");
      debugPrint("Token yang dikirim: '${widget.token}'");
      debugPrint(
        "Mencoba memanggil API: http://10.36.134.108:8000/api/lecturer/courses",
      );

      final response = await http
          .get(
            Uri.parse('http://10.36.134.108:8000/api/lecturer/courses'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${widget.token}',
            },
          )
          .timeout(
            const Duration(seconds: 10),
          ); // Tambahkan timeout agar tidak loading selamanya

      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _courses = data['data'];
          _isLoading = false;
        });
      } else {
        debugPrint("API GAGAL: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("ERROR KONEKSI: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Pilih Kelas",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? const Center(child: Text("Tidak ada kelas yang ditemukan."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      _courses[index]['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Semester ${_courses[index]['semester'] ?? '-'}",
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () {
                      debugPrint("--- CEK TOKEN DI DASHBOARD ---");
                      debugPrint(
                        "Token di Dashboard saat ini: '${widget.token}'",
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScannerPage(
                            userData:
                                widget.userData, // <-- Apakah ini ada datanya?
                            token: widget
                                .token, // <--- PASTIKAN INI ADALAH VARIABEL TOKEN YANG BENAR
                            course:
                                [], // Pastikan course-nya juga tidak kosong jika diperlukan
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
