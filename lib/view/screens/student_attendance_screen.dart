import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/student_attendance_controller.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 20.0, end: 250.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    Get.put(StudentAttendanceController());
  }

  @override
  void dispose() {
    _animationController.dispose();
    scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawCode = barcode.rawValue;
      if (rawCode != null && rawCode.trim().isNotEmpty) {
        setState(() {
          isProcessing = true;
        });

        String extractedToken = rawCode.trim();
        try {
          final decoded = jsonDecode(extractedToken);
          if (decoded is Map<String, dynamic>) {
            extractedToken = (decoded['qr_payload'] ??
                    decoded['qr_token'] ??
                    decoded['token'] ??
                    decoded['code'] ??
                    decoded['data'] ??
                    extractedToken)
                .toString()
                .trim();
          }
        } catch (_) {}

        final controller = Get.find<StudentAttendanceController>();
        await controller.scanStudentQrCode(extractedToken);

        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            setState(() {
              isProcessing = false;
            });
          }
        });

        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = MediaQuery.of(context).size.width * 0.82;

    return Scaffold(
      backgroundColor: App.screenBackgroundColor.first,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'SCAN ATTENDANCE',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.8,
          ),
        ),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Scanner Camera Box
                Center(
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          // Mobile Scanner Camera
                          MobileScanner(
                            controller: scannerController,
                            onDetect: _onDetect,
                            errorBuilder: (context, error, child) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white70,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Camera Permission Needed',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Please allow camera permission in settings.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Green Corners Custom Paint
                          Positioned.fill(
                            child: CustomPaint(
                              painter: GreenCornerPainter(
                                color: const Color(0xFF10B981),
                                cornerLength: 32.0,
                                strokeWidth: 4.5,
                                borderRadius: 28.0,
                              ),
                            ),
                          ),

                          // Animated Green Scan Line
                          if (!isProcessing)
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Positioned(
                                  top: (_animation.value / 280.0) * (boxSize - 40) + 20,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.8),
                                          blurRadius: 10,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Torch / Flash Toggle Button (Top Right)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: ValueListenableBuilder<MobileScannerState>(
                              valueListenable: scannerController,
                              builder: (context, state, child) {
                                final isTorchOn = state.torchState == TorchState.on;
                                return Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                      size: 20,
                                    ),
                                    color: isTorchOn ? Colors.amber : Colors.white,
                                    onPressed: () => scannerController.toggleTorch(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Helper Subtitle Text
                const Text(
                  'Align QR code inside the frame to scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 32),

                // Red Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_rounded, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GreenCornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double borderRadius;

  GreenCornerPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;
    final double r = borderRadius;
    final double l = cornerLength;

    // Top-Left Corner
    final topLeft = Path()
      ..moveTo(0, l)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(l, 0);
    canvas.drawPath(topLeft, paint);

    // Top-Right Corner
    final topRight = Path()
      ..moveTo(w - l, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, l);
    canvas.drawPath(topRight, paint);

    // Bottom-Left Corner
    final bottomLeft = Path()
      ..moveTo(0, h - l)
      ..lineTo(0, h - r)
      ..arcToPoint(Offset(r, h), radius: Radius.circular(r))
      ..lineTo(l, h);
    canvas.drawPath(bottomLeft, paint);

    // Bottom-Right Corner
    final bottomRight = Path()
      ..moveTo(w - l, h)
      ..lineTo(w - r, h)
      ..arcToPoint(Offset(w, h - r), radius: Radius.circular(r))
      ..lineTo(w, h - l);
    canvas.drawPath(bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
