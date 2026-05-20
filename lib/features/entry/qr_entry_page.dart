import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/table_session.dart';
import '../home/home_page.dart';

class QrEntryPage extends StatefulWidget {
  const QrEntryPage({super.key});

  @override
  State<QrEntryPage> createState() => _QrEntryPageState();
}

class _QrEntryPageState extends State<QrEntryPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isHandling = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _extractTableNumber(String raw) {
    final text = raw.trim();
    final upper = text.toUpperCase();

    if (upper.startsWith('TABLE:')) {
      final value = text.substring(6).trim();
      if (value.isNotEmpty) return value;
    }

    if (upper.startsWith('MASA:')) {
      final value = text.substring(5).trim();
      if (value.isNotEmpty) return value;
    }

    final uri = Uri.tryParse(text);
    if (uri != null) {
      final tableFromQuery = uri.queryParameters['table'];
      if (tableFromQuery != null && tableFromQuery.trim().isNotEmpty) {
        return tableFromQuery.trim();
      }

      final segments = uri.pathSegments;
      if (segments.length >= 2 &&
          segments[segments.length - 2].toLowerCase() == 'table') {
        final candidate = segments.last.trim();
        if (candidate.isNotEmpty) return candidate;
      }
    }

    return null;
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isHandling) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue;

    if (raw == null || raw.trim().isEmpty) return;

    final tableNumber = _extractTableNumber(raw);
    if (tableNumber == null) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Geçersiz QR. Örnek format: TABLE:12';
      });
      return;
    }

    _isHandling = true;

    try {
      await _controller.stop();
      await TableSession.instance.setTable(tableNumber);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(tableNumber: tableNumber),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = 'QR işlenemedi: $e';
      });

      _isHandling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8F4FA);
    const dark = Color(0xFF2F2A33);
    const orange = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 52,
                      color: orange,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'MenuMate Giriş',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: dark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Devam etmek için masanıza ait QR kodunu okutun.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Color(0xFF6B6670),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: MobileScanner(
                          controller: _controller,
                          onDetect: _handleBarcode,
                          errorBuilder: (context, error) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Kamera açılamadı.\nTarayıcı kamera iznini kontrol et.\n\n$error',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'QR kodu kameraya hizalayın',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              if (_errorText != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _errorText!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFFCA5A5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'Test QR içeriği örneği: TABLE:12',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9A4311),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
