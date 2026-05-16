import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/driver_bloc.dart';

class QrScannerScreen extends StatefulWidget {
  final int orderId;
  final String type; // 'pickup' or 'delivery'

  const QrScannerScreen({
    super.key,
    required this.orderId,
    required this.type,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  bool get _isPickup => widget.type == 'pickup';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    try {
      final data = jsonDecode(barcode!.rawValue!) as Map<String, dynamic>;
      final scannedOrderId = data['orderId'] as int?;
      final qrToken = data['qrToken'] as String?;

      if (scannedOrderId == null || qrToken == null) {
        _showError('Invalid QR code format');
        return;
      }

      if (scannedOrderId != widget.orderId) {
        _showError('QR code does not match this order');
        return;
      }

      setState(() => _scanned = true);
      _controller.stop();

      final bloc = context.read<DriverBloc>();
      if (_isPickup) {
        bloc.add(ConfirmPickup(orderId: widget.orderId, qrToken: qrToken));
      } else {
        bloc.add(ConfirmDelivery(orderId: widget.orderId, qrToken: qrToken));
      }

      context.pop();
    } catch (e) {
      _showError('Could not read QR code');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(_isPickup ? 'Scan Pickup QR' : 'Scan Delivery QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          // Bottom instructions
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPickup ? Icons.restaurant : Icons.home,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPickup
                        ? 'Scan the QR code at the restaurant\nto confirm order pickup'
                        : 'Scan the customer\'s QR code\nto confirm delivery',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final scanAreaSize = size.width * 0.65;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12))),
      ),
      paint,
    );

    // Corner indicators
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const cornerLen = 24.0;

    // Top-left
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(left + scanAreaSize - cornerLen, top), Offset(left + scanAreaSize, top), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top), Offset(left + scanAreaSize, top + cornerLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(left, top + scanAreaSize - cornerLen), Offset(left, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left, top + scanAreaSize), Offset(left + cornerLen, top + scanAreaSize), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(left + scanAreaSize - cornerLen, top + scanAreaSize), Offset(left + scanAreaSize, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top + scanAreaSize - cornerLen), Offset(left + scanAreaSize, top + scanAreaSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
