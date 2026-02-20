import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Manages a persistent MobileScannerController to avoid rapid init/dispose cycles.
class ScannerService {
  // Singleton instance
  static final ScannerService _instance = ScannerService._internal();
  static ScannerService get instance => _instance;

  ScannerService._internal();

  MobileScannerController? _controller;
  Timer? _disposalTimer;
  
  // Keep-alive duration: 30 seconds
  static const Duration _keepAliveDuration = Duration(seconds: 30);

  Future<MobileScannerController> getController() async {
    // 1. Cancel any pending disposal
    _disposalTimer?.cancel();
    _disposalTimer = null;

    // 2. Return existing controller if available
    if (_controller != null) {
      return _controller!;
    }

    // 3. Create and start new controller
    debugPrint('ScannerService: Creating new controller...');
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: false, 
    );
    
    _controller = controller;

    debugPrint('ScannerService: Starting controller in background...');
    controller.start().catchError((e) {
      debugPrint('ScannerService: Background start error: $e');
      if (_controller == controller) {
         _controller = null;
      }
    });
      
    return controller;
  }

  /// Notifies the service that a consumer is done with the controller.
  /// The service will wait for [_keepAliveDuration] before actually disposing.
  void releaseController() {
    _disposalTimer?.cancel();
    _disposalTimer = Timer(_keepAliveDuration, _disposeActual);
  }

  /// Force disposal immediately (app exit, etc.)
  void disposeImmediately() {
    _disposalTimer?.cancel();
    _disposeActual();
  }

  void _disposeActual() {
    debugPrint('ScannerService: Disposing controller due to inactivity.');
    try {
      _controller?.dispose();
    } catch (e) {
      debugPrint('ScannerService: Error disposing controller: $e');
    }
    _controller = null;
  }
}
