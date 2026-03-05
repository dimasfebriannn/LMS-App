import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailAssignmentPage extends StatefulWidget {
  final Map<String, dynamic> task;
  final Color primaryColor;
  final Map<String, dynamic> userData;

  const DetailAssignmentPage({
    super.key,
    required this.task,
    required this.primaryColor,
    required this.userData,
  });

  @override
  State<DetailAssignmentPage> createState() => _DetailAssignmentPageState();
}

class _DetailAssignmentPageState extends State<DetailAssignmentPage> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  bool _isSubmitted = false; // Status apakah tugas sudah pernah dikumpul

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus(); // Cek status saat halaman dibuka
  }

  // FUNGSI CEK STATUS KE LARAVEL
  Future<void> _checkSubmissionStatus() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://10.36.134.108:8000/api/submissions/check/${widget.userData['id']}/${widget.task['id']}",
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isSubmitted = data['submitted'];
        });
      }
    } catch (e) {
      debugPrint("Error check status: $e");
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadAssignment() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    try {
      var uri = Uri.parse("http://10.36.134.108:8000/api/submissions");
      var request = http.MultipartRequest("POST", uri);
      request.headers.addAll({'Accept': 'application/json'});

      request.fields['user_id'] = widget.userData['id'].toString();
      request.fields['assignment_id'] = widget.task['id'].toString();

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        _selectedFile!.path,
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Tugas berhasil dikirim!"),
            ),
          );
          _checkSubmissionStatus(); // Refresh status setelah upload berhasil
        }
      } else {
        _showErrorSnackBar("Gagal mengunggah tugas.");
      }
    } catch (e) {
      _showErrorSnackBar("Koneksi terputus!");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Tugas",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.task['course']['title']?.toUpperCase() ??
                          'MATA KULIAH',
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.task['title'] ?? 'Judul Tugas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildInfoTile(
                        Icons.calendar_today_rounded,
                        "Batas Waktu",
                        widget.task['deadline'] ?? '-',
                        Colors.orange,
                      ),
                      const SizedBox(width: 20),
                      // Update Status secara Real-time
                      _buildInfoTile(
                        Icons.check_circle_outline_rounded,
                        "Status",
                        _isSubmitted
                            ? "Terverifikasi"
                            : (_selectedFile != null
                                  ? "Siap Kirim"
                                  : "Belum Kirim"),
                        _isSubmitted ? Colors.green : Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Instruksi Tugas",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Text(
                      widget.task['description'] ?? 'Tidak ada deskripsi.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Lampiran Tugas",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // LOGIKA UI: Jika sudah submit, tampilkan banner sukses. Jika belum, tampilkan upload picker
                  _isSubmitted
                      ? _buildSuccessBanner()
                      : _buildUploadPlaceholder(),

                  const SizedBox(height: 40),

                  if (!_isSubmitted) // Sembunyikan tombol jika sudah submit
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_selectedFile == null || _isUploading)
                            ? null
                            : _uploadAssignment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Kumpulkan Tugas",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade100, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, size: 48, color: Colors.green),
          const SizedBox(height: 12),
          Text(
            "Tugas Telah Dikumpulkan",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Kamu tidak dapat mengirim ulang tugas ini.",
            style: TextStyle(color: Colors.green.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedFile != null
                ? widget.primaryColor
                : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFile != null
                  ? Icons.insert_drive_file_rounded
                  : Icons.cloud_upload_outlined,
              size: 42,
              color: _selectedFile != null
                  ? widget.primaryColor
                  : Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFile != null
                  ? _fileName!
                  : "Pilih file tugas (.pdf, .zip, .docx)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _selectedFile != null
                    ? widget.primaryColor
                    : Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
