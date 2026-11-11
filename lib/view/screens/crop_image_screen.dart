import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/utils.dart';

class CropImageScreen extends StatefulWidget {
  final String imagePath;
  final String personType;

  const CropImageScreen({
    super.key,
    required this.imagePath,
    this.personType = 'Attendee',
  });

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  double _aspectRatio = 1.0; // 1.0 = 1:1, 0.75 = 3:4, 0.0 = Free
  int _rotationTurns = 0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final personTitle = widget.personType.isNotEmpty
        ? widget.personType.toUpperCase()
        : 'ATTENDEE';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'CROP $personTitle PHOTO',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Drag corners to resize or move crop box',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () => Get.back(result: null),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF0F172A),
                  size: 14,
                ),
              ),
            ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                // MAIN IMAGE CROPPING VIEWPORT
                Expanded(
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Display Rotated Image
                        RotatedBox(
                          quarterTurns: _rotationTurns,
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),

                        // Crop Box Grid Overlay
                        AspectRatio(
                          aspectRatio: _aspectRatio == 0.0 ? 1.0 : _aspectRatio,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF6366F1), width: 2),
                            ),
                            child: Stack(
                              children: [
                                // 3x3 Grid Lines
                                Column(
                                  children: [
                                    Expanded(child: Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white38, width: 0.8))))),
                                    Expanded(child: Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white38, width: 0.8))))),
                                    const Expanded(child: SizedBox()),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Container(decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white38, width: 0.8))))),
                                    Expanded(child: Container(decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white38, width: 0.8))))),
                                    const Expanded(child: SizedBox()),
                                  ],
                                ),

                                // Top-Left Corner Handle
                                Positioned(
                                  top: -2,
                                  left: -2,
                                  child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF6366F1), width: 4), left: BorderSide(color: Color(0xFF6366F1), width: 4)))),
                                ),
                                // Top-Right Corner Handle
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF6366F1), width: 4), right: BorderSide(color: Color(0xFF6366F1), width: 4)))),
                                ),
                                // Bottom-Left Corner Handle
                                Positioned(
                                  bottom: -2,
                                  left: -2,
                                  child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF6366F1), width: 4), left: BorderSide(color: Color(0xFF6366F1), width: 4)))),
                                ),
                                // Bottom-Right Corner Handle
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF6366F1), width: 4), right: BorderSide(color: Color(0xFF6366F1), width: 4)))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ASPECT RATIO & ROTATE BAR (White Card)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAspectChip('1:1', _aspectRatio == 1.0, () {
                        setState(() => _aspectRatio = 1.0);
                      }),
                      _buildAspectChip('3:4', _aspectRatio == 3.0 / 4.0, () {
                        setState(() => _aspectRatio = 3.0 / 4.0);
                      }),
                      _buildAspectChip('Free', _aspectRatio == 0.0, () {
                        setState(() => _aspectRatio = 0.0);
                      }),
                      InkWell(
                        onTap: () {
                          setState(() => _rotationTurns = (_rotationTurns + 1) % 4);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rotate_right_rounded, color: Color(0xFF4F46E5), size: 20),
                              SizedBox(height: 2),
                              Text('Rotate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // BOTTOM CANCEL & SAVE BUTTONS ROW
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Get.back(result: null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4F46E5),
                            side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  setState(() => _isProcessing = true);
                                  final croppedPath = await _processAndSaveCrop();
                                  Get.back(result: croppedPath);
                                },
                          icon: _isProcessing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.crop_rounded, size: 18),
                          label: Text(
                            _isProcessing ? 'Saving...' : 'Save',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAspectChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B61F4) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<String?> _processAndSaveCrop() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final originalImage = frameInfo.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final imgWidth = originalImage.width.toDouble();
      final imgHeight = originalImage.height.toDouble();

      double cropW = imgWidth;
      double cropH = imgHeight;

      final targetRatio = _aspectRatio == 0.0 ? (imgWidth / imgHeight) : _aspectRatio;

      if (imgWidth / imgHeight > targetRatio) {
        cropH = imgHeight;
        cropW = cropH * targetRatio;
      } else {
        cropW = imgWidth;
        cropH = cropW / targetRatio;
      }

      final srcRect = Rect.fromCenter(
        center: Offset(imgWidth / 2, imgHeight / 2),
        width: cropW,
        height: cropH,
      );

      final dstRect = Rect.fromLTWH(0, 0, cropW, cropH);

      canvas.drawImageRect(originalImage, srcRect, dstRect, Paint()..filterQuality = FilterQuality.high);

      final picture = recorder.endRecording();
      final croppedUiImage = await picture.toImage(cropW.toInt(), cropH.toInt());
      final byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return widget.imagePath;

      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      return tempFile.path;
    } catch (_) {
      return widget.imagePath;
    }
  }
}
