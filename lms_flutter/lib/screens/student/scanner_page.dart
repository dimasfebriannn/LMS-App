import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const ScannerPage({
    super.key,
    required this.userData,
    required this.token,
    required List<dynamic> course, // Tambahkan di constructor
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Scan Presensi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (capture) {
          if (!isScanCompleted) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              isScanCompleted = true; // Kunci biar tidak scan berulang
              String code = barcode.rawValue ?? "";
              _handleAttendance(code);
            }
          }
        },
      ),
    );
  }

  Future<void> _handleAttendance(String scannedCode) async {
    debugPrint("--- CEK TOKEN SCANNER ---");
    debugPrint("Token yang dibawa: '${widget.token}'");
    debugPrint("URL yang dituju: http://10.36.134.108:8000/api/attend");
    try {
      // 1. Parsing JSON dari QR Code
      final Map<String, dynamic> decodedData = json.decode(scannedCode);

      // 2. Kirim ke API dengan Data Dinamis
      final response = await http.post(
        Uri.parse('http://10.36.134.108:8000/api/attend'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'user_id': widget.userData['id'].toString(), // Dari user login
          'course_id': decodedData['course_id'].toString(),
          'token': decodedData['token'], // Token dari QR
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _showResultDialog("Berhasil!", data['message'], Colors.green);
      } else {
        _showResultDialog(
          "Gagal",
          data['message'] ?? "QR tidak valid",
          Colors.orange,
        );
      }
    } catch (e) {
      _showResultDialog("Error", "Server tidak merespon.", Colors.red);
      debugPrint("SCAN ERROR: $e");
    }
  }

  void _showResultDialog(String title, String msg, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
