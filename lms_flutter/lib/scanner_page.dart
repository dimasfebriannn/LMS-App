import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required course});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool isScanCompleted = false;

  void closeScreen() {
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Scan Presensi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Arahkan kamera ke QR Code",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pastikan kode berada di dalam kotak",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- KAMERA SCANNER ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: MobileScanner(
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.noDuplicates,
                        facing: CameraFacing.back,
                      ),
                      onDetect: (capture) {
                        if (!isScanCompleted) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            isScanCompleted = true;
                            String code = barcode.rawValue ?? "---";
                            _handleAttendance(code);
                          }
                        }
                      },
                    ),
                  ),
                  // --- OVERLAY KOTAK (Hiasan) ---
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on_rounded, color: Colors.white54),
                  SizedBox(width: 20),
                  Icon(Icons.flip_camera_ios_rounded, color: Colors.white54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk memproses data hasil scan ke API Laravel
  Future<void> _handleAttendance(String scannedCode) async {
    // Kita asumsikan isi QR Code adalah ID Mata Kuliah (misal: "1")
    const String apiUrl = 'http://10.114.52.108:8000/api/attendance';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
        body: {
          'user_id':
              '1', // Sementara hardcode atau ambil dari widget.userData['id']
          'course_id': scannedCode,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _showResultDialog("Berhasil!", data['message'], Colors.green);
      } else {
        _showResultDialog("Gagal", data['message'], Colors.orange);
      }
    } catch (e) {
      _showResultDialog("Error", "Gagal terhubung ke server.", Colors.red);
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
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke Dashboard
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
