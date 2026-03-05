import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart'; // Pastikan sudah install package qr_flutter

class QrGeneratorPage extends StatefulWidget {
  final int courseId;
  final String token;
  const QrGeneratorPage({super.key, required this.courseId, required this.token});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  String? _qrData;
  bool _isLoading = false;

  Future<void> _generateQR() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.36.134.108:8000/api/lecturer/generate-qr'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {'course_id': widget.courseId.toString()}, // Mengirim ID kelas
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          // Asumsi backend mengembalikan string unik untuk QR
          _qrData = data['data']['qr_payload']; // Sesuaikan dengan struktur response backend
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal generate QR")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate QR")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_qrData != null)
              QrImageView(
                data: _qrData!,
                version: QrVersions.auto,
                size: 250.0,
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateQR,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Generate QR Sekarang"),
            ),
          ],
        ),
      ),
    );
  }
}