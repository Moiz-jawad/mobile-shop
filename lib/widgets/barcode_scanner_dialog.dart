import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/scanner_service.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  bool _scanned = false;
  MobileScannerController? controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final serviceController = await ScannerService.instance.getController();
      if (!mounted) return;
      setState(() {
        controller = serviceController;
      });
    } catch (e) {
      debugPrint('Error getting scanner controller: $e');
    }
  }

  @override
  void dispose() {
    // Release the controller back to the service (it will keep it alive for a bit)
    ScannerService.instance.releaseController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan IMEI'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (controller == null) {
             if (snapshot.hasError) {
               return Center(
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Icon(Icons.error_outline, color: Colors.red, size: 48),
                     const SizedBox(height: 16),
                     Text('Camera Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                     const SizedBox(height: 16),
                     ElevatedButton(
                       onPressed: () {
                         // Force a hard reset of the scanner service
                         ScannerService.instance.disposeImmediately();
                         setState(() {
                           _initFuture = _initializeCamera();
                         });
                       },
                       child: const Text('Retry'),
                     ),
                   ],
                 ),
               );
             }
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Initializing Camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              MobileScanner(
                controller: controller!,
                errorBuilder: (context, error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Camera Error: ${error.errorCode}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _initFuture = _initializeCamera();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
                onDetect: (capture) {
                  if (_scanned) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null) {
                      setState(() {
                        _scanned = true;
                      });
                      Navigator.pop(context, code);
                    }
                  }
                },
              ),
              // Overlay guide
              Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: Theme.of(context).primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                ),
              ),
              if (_scanned)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Custom overlay shape helper (simplified version of common library code)
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    // Use fields directly or standard local variable names
    final cutOutSizeVal = cutOutSize;
    final borderRadiusVal = borderRadius;
    final borderLengthVal = borderLength;
    final borderColorVal = borderColor;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColorVal
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cutOutSizeVal / 2 + borderOffset,
      rect.top + height / 2 - cutOutSizeVal / 2 + borderOffset,
      cutOutSizeVal - borderWidth,
      cutOutSizeVal - borderWidth,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadiusVal),
        ),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    final rRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadiusVal),
    );

    // Draw corners
    final path = Path();
    
    // Top left
    path.moveTo(rRect.left, rRect.top + borderLengthVal);
    path.lineTo(rRect.left, rRect.top + borderRadiusVal);
    path.arcToPoint(
      Offset(rRect.left + borderRadiusVal, rRect.top),
      radius: Radius.circular(borderRadiusVal),
    );
    path.lineTo(rRect.left + borderLengthVal, rRect.top);

    // Top right
    path.moveTo(rRect.right - borderLengthVal, rRect.top);
    path.lineTo(rRect.right - borderRadiusVal, rRect.top);
    path.arcToPoint(
      Offset(rRect.right, rRect.top + borderRadiusVal),
      radius: Radius.circular(borderRadiusVal),
    );
    path.lineTo(rRect.right, rRect.top + borderLengthVal);

    // Bottom right
    path.moveTo(rRect.right, rRect.bottom - borderLengthVal);
    path.lineTo(rRect.right, rRect.bottom - borderRadiusVal);
    path.arcToPoint(
      Offset(rRect.right - borderRadiusVal, rRect.bottom),
      radius: Radius.circular(borderRadiusVal),
    );
    path.lineTo(rRect.right - borderLengthVal, rRect.bottom);

    // Bottom left
    path.moveTo(rRect.left + borderLengthVal, rRect.bottom);
    path.lineTo(rRect.left + borderRadiusVal, rRect.bottom);
    path.arcToPoint(
      Offset(rRect.left, rRect.bottom - borderRadiusVal),
      radius: Radius.circular(borderRadiusVal),
    );
    path.lineTo(rRect.left, rRect.bottom - borderLengthVal);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
