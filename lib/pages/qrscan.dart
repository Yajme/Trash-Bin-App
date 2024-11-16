import 'dart:typed_data';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
class QRScan extends StatefulWidget {
  QRScan({super.key});
  @override
  State<QRScan > createState() => _StateQRScan ();
}

class _StateQRScan  extends State<QRScan > {
  MobileScannerController controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true
        );
  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(center: MediaQuery.sizeOf(context).center(Offset.zero), width: 200, height: 200);

    return Scaffold(
      appBar: AppBar(
        title: Text('QRScan'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
        controller:MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (capture){
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;

          //TODO : Scan QR from raspberry pi to enable conversion of waste to points
        },
      ),
       QRScannerOverlay()
        ],
      )
    );
  }
}


// Creates the white borders
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 4.0;
    const radius = 20.0;
    const tRadius = 3 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const clippingRect0 = Rect.fromLTWH(
      0,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius,
      tRadius,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.height - tRadius,
      tRadius,
      tRadius,
    );

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BarReaderSize {
  static double width = 200;
  static double height = 200;
}

class OverlayWithHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          Path()
            ..addOval(Rect.fromCircle(
                center: Offset(size.width - 44, size.height - 44), radius: 40))
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

@override
bool shouldRepaint(CustomPainter oldDelegate) {
  return false;
}
/*
class ScannerOverlay extends CustomPainter{
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }
}

*/