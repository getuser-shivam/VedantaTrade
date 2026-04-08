import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../shared/theme/enhanced_app_theme.dart';

/// Barcode Scanner Screen
/// Uses mobile_scanner package to scan product barcodes
class BarcodeScannerScreen extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const BarcodeScannerScreen({
    Key? key,
    required this.onBarcodeDetected,
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      setState(() {
        _isScanning = false;
      });
      
      // Vibrate on successful scan
      // HapticFeedback.lightImpact();
      
      // Return the barcode value
      widget.onBarcodeDetected(barcode.rawValue!);
      Navigator.of(context).pop(barcode.rawValue);
    }
  }

  void _toggleTorch() {
    controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan Barcode',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            overlay: _buildScannerOverlay(theme),
          ),

          // Scanner Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Position the barcode within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Cancel Button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
      ),
      child: CustomPaint(
        painter: ScannerOverlayPainter(),
        child: const Center(),
      ),
    );
  }
}

/// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw dark overlay around scan area
    final scanAreaSize = size.width * 0.7;
    final scanAreaOffset = (size.width - scanAreaSize) / 2;

    // Top overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, scanAreaOffset),
      paint,
    );

    // Bottom overlay
    canvas.drawRect(
      Rect.fromLTWH(0, scanAreaOffset + scanAreaSize, size.width, size.height - scanAreaOffset - scanAreaSize),
      paint,
    );

    // Left overlay
    canvas.drawRect(
      Rect.fromLTWH(0, scanAreaOffset, scanAreaOffset, scanAreaSize),
      paint,
    );

    // Right overlay
    canvas.drawRect(
      Rect.fromLTWH(scanAreaOffset + scanAreaSize, scanAreaOffset, scanAreaOffset, scanAreaSize),
      paint,
    );

    // Draw corner markers
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(scanAreaOffset, scanAreaOffset),
      Offset(scanAreaOffset + cornerLength, scanAreaOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaOffset, scanAreaOffset),
      Offset(scanAreaOffset, scanAreaOffset + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanAreaOffset + scanAreaSize - cornerLength, scanAreaOffset),
      Offset(scanAreaOffset + scanAreaSize, scanAreaOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaOffset + scanAreaSize, scanAreaOffset),
      Offset(scanAreaOffset + scanAreaSize, scanAreaOffset + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanAreaOffset, scanAreaOffset + scanAreaSize - cornerLength),
      Offset(scanAreaOffset, scanAreaOffset + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaOffset, scanAreaOffset + scanAreaSize),
      Offset(scanAreaOffset + cornerLength, scanAreaOffset + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanAreaOffset + scanAreaSize - cornerLength, scanAreaOffset + scanAreaSize),
      Offset(scanAreaOffset + scanAreaSize, scanAreaOffset + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaOffset + scanAreaSize, scanAreaOffset + scanAreaSize - cornerLength),
      Offset(scanAreaOffset + scanAreaSize, scanAreaOffset + scanAreaSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
