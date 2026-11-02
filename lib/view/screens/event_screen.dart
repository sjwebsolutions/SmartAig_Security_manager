import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:security_manager/models/event_scan_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view/screens/event_scan_result_screen.dart';
import 'package:security_manager/view_models/event_controller.dart';

class EventScreen extends StatefulWidget {
  final bool showBackButton;

  const EventScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController _searchController = TextEditingController();
  bool isProcessingScan = false;

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

    Get.put(EventController());
  }

  @override
  void dispose() {
    _animationController.dispose();
    scannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessingScan) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawCode = barcode.rawValue;
      if (rawCode != null && rawCode.trim().isNotEmpty) {
        setState(() {
          isProcessingScan = true;
        });

        String extractedPayload = rawCode.trim();

        // Pass exact payload string to API
        final controller = Get.find<EventController>();
        final result = await controller.scanEventPass(extractedPayload);

        if (result != null && mounted) {
          try {
            await scannerController.stop();
          } catch (_) {}

          // Navigate to dedicated Event Scan Result Screen & WAIT for OK button press
          await Get.to(() => EventScanResultScreen(scanResult: result));

          // Resume camera scanning after user presses OK and returns back
          try {
            await scannerController.start();
          } catch (_) {}
        }

        if (mounted) {
          setState(() {
            isProcessingScan = false;
          });
        }

        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        centerTitle: true,
        title: const Text(
          'EVENTS & SCANS',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.8,
          ),
        ),
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        leadingWidth: widget.showBackButton ? 70 : 0,
        leading: widget.showBackButton
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEEF2FF),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF0F172A),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
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
          child: Column(
            children: [
              // Top Segmented Tab Switcher
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final selectedIndex = controller.selectedTabIndex.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSegmentedTab(
                            title: 'Pass Scan',
                            icon: Icons.qr_code_scanner_rounded,
                            isSelected: selectedIndex == 0,
                            onTap: () async {
                              controller.selectedTabIndex.value = 0;
                              if (mounted) {
                                setState(() {
                                  isProcessingScan = false;
                                });
                              }
                              try {
                                await scannerController.start();
                              } catch (_) {}
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentedTab(
                            title: 'View Gate Pass',
                            icon: Icons.badge_outlined,
                            isSelected: selectedIndex == 1,
                            onTap: () async {
                              controller.selectedTabIndex.value = 1;
                              try {
                                await scannerController.stop();
                              } catch (_) {}
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // Dynamic Tab Body
              Expanded(
                child: Obx(() {
                  if (controller.selectedTabIndex.value == 0) {
                    return _buildPassScanView(context);
                  } else {
                    return _buildViewGatePassView(context, controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5340FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: PASS SCAN VIEW
  Widget _buildPassScanView(BuildContext context) {
    final double boxSize = MediaQuery.of(context).size.width * 0.82;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Instruction Title
            const Text(
              'Point camera at the Event Pass QR / Barcode',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            const Text(
              'Pass scan will be validated automatically upon detection',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // Scanner Box
            Center(
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Camera
                      MobileScanner(
                        controller: scannerController,
                        onDetect: _onDetect,
                        errorBuilder: (context, error, child) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00E5FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.priority_high_rounded,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Scanning is not supported on this device.\nNo cameras available.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Inner Target Square Frame
                      Center(
                        child: Container(
                          width: boxSize * 0.72,
                          height: boxSize * 0.72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // Animated Scan Cyan Line
                      if (!isProcessingScan)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: (_animation.value / 280.0) * (boxSize - 60) + 30,
                              left: 30,
                              right: 30,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                      blurRadius: 12,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Torch / Flash Toggle Button
                      Positioned(
                        top: 14,
                        right: 14,
                        child: ValueListenableBuilder<MobileScannerState>(
                          valueListenable: scannerController,
                          builder: (context, state, child) {
                            final isTorchOn = state.torchState == TorchState.on;
                            return Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                  size: 18,
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

            const SizedBox(height: 36),

            // Red Cancel Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Get.back(),
                icon: const Icon(Icons.cancel_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'CANCEL',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // TAB 2: VIEW GATE PASS / TODAY SCANS VIEW
  Widget _buildViewGatePassView(BuildContext context, EventController controller) {
    return Column(
      children: [
        // Statistics Summary Bar
        Obx(() {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S VALID SCANS",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Verified pass entries recorded today',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      "${controller.totalValidScansToday.value}",
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 6),

        // Today Scans List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.scans.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5340FF),
                ),
              );
            }

            if (controller.hasError.value && controller.scans.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchTodayScans(isUserRefresh: true),
                color: const Color(0xFF5340FF),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                            const SizedBox(height: 12),
                            Text(
                              controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : 'Failed to load today scans',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchTodayScans(isUserRefresh: true),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5340FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final displayScans = controller.scans;

            if (displayScans.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchTodayScans(isUserRefresh: true),
                color: const Color(0xFF5340FF),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No event scans recorded today',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchTodayScans(isUserRefresh: true),
              color: const Color(0xFF5340FF),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: displayScans.length,
                itemBuilder: (context, index) {
                  final scan = displayScans[index];
                  return _buildScanCard(scan);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildScanCard(EventScanItemModel scan) {
    final bool isAlreadyEntered =
        scan.scanStatus.toLowerCase().contains('already') ||
        scan.scanMessage.toUpperCase().contains('DUPLICATE');

    final Color statusColor = isAlreadyEntered
        ? const Color(0xFFD97706)
        : const Color(0xFF16A34A);

    final Color statusBg = isAlreadyEntered
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF0FDF4);

    final Color statusBorder = isAlreadyEntered
        ? const Color(0xFFFDE68A)
        : const Color(0xFFBBF7D0);

    final String statusText = isAlreadyEntered
        ? 'ALREADY ADMITTED'
        : (scan.scanStatus.isNotEmpty ? scan.scanStatus.replaceAll('_', ' ').toUpperCase() : 'VALID SCAN');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Text(
                  scan.passNumber,
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusBorder),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            scan.studentName,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Event: ${scan.eventTitle}',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (scan.classSection.isNotEmpty) ...[
                Text(
                  ' | ${scan.classSection}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),

          if (scan.admissionNo.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Admission No: ${scan.admissionNo}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],

          if (scan.scanMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAlreadyEntered
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAlreadyEntered
                      ? const Color(0xFFFECACA)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isAlreadyEntered
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    color: isAlreadyEntered
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF0284C7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scan.scanMessage,
                      style: TextStyle(
                        color: isAlreadyEntered
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF334155),
                        fontSize: 11.5,
                        height: 1.3,
                        fontWeight: isAlreadyEntered
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(color: Color(0xFFE2E8F0), height: 20),

          Row(
            children: [
              const Icon(Icons.door_sliding_rounded, color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  scan.gateName.isNotEmpty ? scan.gateName : 'Main Gate',
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 4),
              Text(
                scan.scannedAtFull.isNotEmpty
                    ? scan.scannedAtFull
                    : scan.scannedAt,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
