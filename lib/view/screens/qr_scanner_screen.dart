import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/dashboard_controller.dart';

class QrScannerScreen extends StatefulWidget {
  final String action; // 'clock_in', 'clock_out', or 'student_attendance'
  final Function(String code)? onScanResult;

  const QrScannerScreen({
    super.key,
    required this.action,
    this.onScanResult,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isHandled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 230.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isHandled) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        setState(() {
          isHandled = true;
        });
        scannerController.stop();

        String extractedToken = code.trim();
        try {
          final decoded = jsonDecode(extractedToken);
          if (decoded is Map<String, dynamic>) {
            extractedToken = (decoded['qr_token'] ??
                    decoded['token'] ??
                    decoded['code'] ??
                    decoded['data'] ??
                    extractedToken)
                .toString()
                .trim();
          }
        } catch (_) {}

        if (widget.onScanResult != null) {
          Get.back();
          widget.onScanResult!(extractedToken);
          return;
        }

        try {
          final DashboardController dashboardController = Get.find<DashboardController>();
          dashboardController.qrTokenController.text = extractedToken;

          // Close scanner screen immediately so it never freezes or hangs
          Get.back();

          // Trigger clock in / out API on dashboard screen
          dashboardController.clockAttendance(widget.action);
        } catch (_) {
          Get.back(result: extractedToken);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double boxSize = 260.0;
    String screenTitle = 'Scan QR Code';
    if (widget.action == 'clock_in') {
      screenTitle = 'Scan QR for Clock In';
    } else if (widget.action == 'clock_out') {
      screenTitle = 'Scan QR for Clock Out';
    } else if (widget.action == 'student_attendance') {
      screenTitle = 'Scan Student Attendance QR';
    }

    return Scaffold(
      backgroundColor: App.screenBackgroundColor.first,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          screenTitle.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 17,
            letterSpacing: 0.5,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: App.screenBackgroundColor,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double scanTop = 90.0;
            final scanRect = Rect.fromLTWH(
              (constraints.maxWidth - boxSize) / 2,
              scanTop,
              boxSize,
              boxSize,
            );

            return Stack(
              children: [
                // Camera scanner background
                MobileScanner(
                  controller: scannerController,
                  onDetect: _onDetect,
                ),

                // Overlay Mask around the Scanner Cutout
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(
                      scanBox: scanRect,
                      borderRadius: 20,
                    ),
                  ),
                ),

                // Scanner Box Frame with Line, Torch & Switch Camera
                Positioned(
                  left: scanRect.left,
                  top: scanRect.top,
                  width: boxSize,
                  height: boxSize,
                  child: Stack(
                    children: [
                      // Outer Border Box
                      Container(
                        width: boxSize,
                        height: boxSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0284C7), width: 3),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                        ),
                      ),

                      // Animated Scanning Line
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Positioned(
                            top: _animation.value + 12,
                            left: 15,
                            right: 15,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.8),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Torch Button Inside Top-Right of Scanner Frame
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ValueListenableBuilder<MobileScannerState>(
                          valueListenable: scannerController,
                          builder: (context, state, child) {
                            final isTorchOn = state.torchState == TorchState.on;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                color: isTorchOn ? Colors.amber : Colors.white70,
                                icon: Icon(isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
                                iconSize: 22.0,
                                onPressed: () => scannerController.toggleTorch(),
                              ),
                            );
                          },
                        ),
                      ),

                      // Switch Camera Button Inside Top-Left of Scanner Frame
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            color: Colors.white70,
                            icon: const Icon(Icons.cameraswitch_rounded),
                            iconSize: 22.0,
                            onPressed: () => scannerController.switchCamera(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cancel Button 20px below Scanner Box
                Positioned(
                  top: scanRect.bottom + 20,
                  left: 45,
                  right: 45,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanBox;
  final double borderRadius;

  ScannerOverlayPainter({
    required this.scanBox,
    this.borderRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanBox,
          Radius.circular(borderRadius),
        ),
      );

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: App.screenBackgroundColor
            .map((color) => color.withValues(alpha: 0.85))
            .toList(),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
