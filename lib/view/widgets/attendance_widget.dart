import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/dashboard_controller.dart';

class AttendanceWidget extends StatelessWidget {
  const AttendanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  "SCAN ATTENDANCE",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(() {
                final isClockedIn = controller.isClockedIn.value;
                final outTime = controller.clockOutTime.value;
                final rawStatus = controller.attendanceStatus.value.toLowerCase();

                String statusText = "Not Marked Yet";
                Color statusColor = const Color(0xFFD97706);
                Color statusBgColor = const Color(0xFFFFFBEB);

                if (rawStatus == 'absent') {
                  statusText = "Absent";
                  statusColor = const Color(0xFFDC2626);
                  statusBgColor = const Color(0xFFFEF2F2);
                } else if (outTime.isNotEmpty || rawStatus == 'clock_out' || rawStatus == 'clocked_out') {
                  statusText = "Clocked Out";
                  statusColor = const Color(0xFFEA580C);
                  statusBgColor = const Color(0xFFFFF7ED);
                } else if (isClockedIn || rawStatus == 'present' || rawStatus == 'clock_in' || rawStatus == 'clocked_in') {
                  statusText = "Present";
                  statusColor = const Color(0xFF16A34A);
                  statusBgColor = const Color(0xFFF0FDF4);
                } else {
                  statusText = "Not Marked Yet";
                  statusColor = const Color(0xFFD97706);
                  statusBgColor = const Color(0xFFFFFBEB);
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 18),

          // Clock In & Clock Out Buttons / Loading State
          Obx(() {
            if (controller.isAttendanceLoading.value) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.teal.shade700,
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Processing Attendance...",
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            final isClockedIn = controller.isClockedIn.value;
            final inTime = controller.clockInTime.value;
            final outTime = controller.clockOutTime.value;
            final rawStatus = controller.attendanceStatus.value.toLowerCase();

            final hasClockedIn = isClockedIn || inTime.isNotEmpty || rawStatus == 'present' || rawStatus == 'clock_in' || rawStatus == 'clocked_in';
            final hasClockedOut = outTime.isNotEmpty || rawStatus == 'clocked_out' || rawStatus == 'clock_out';

            final isClockInDisabled = hasClockedIn || hasClockedOut;
            final isClockOutDisabled = !hasClockedIn || hasClockedOut;

            return Row(
              children: [
                // Clock In Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFDCFCE7),
                      disabledForegroundColor: const Color(0xFF15803D),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isClockInDisabled ? const Color(0xFF86EFAC) : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      elevation: isClockInDisabled ? 0 : 3,
                    ),
                    onPressed: isClockInDisabled
                        ? null
                        : () {
                            controller.openScannerIfLocationEnabled('clock_in');
                          },
                    icon: Icon(
                      isClockInDisabled ? Icons.check_circle_rounded : Icons.qr_code_scanner_rounded,
                      size: 18,
                      color: isClockInDisabled ? const Color(0xFF16A34A) : Colors.white,
                    ),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Clock In",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isClockInDisabled ? const Color(0xFF15803D) : Colors.white,
                          ),
                        ),
                        if (hasClockedIn) ...[
                          const SizedBox(height: 2),
                          Text(
                            inTime.isNotEmpty ? inTime : "In Marked",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Clock Out Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFFEE2E2),
                      disabledForegroundColor: const Color(0xFFB91C1C),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isClockOutDisabled ? const Color(0xFFFCA5A5) : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      elevation: isClockOutDisabled ? 0 : 3,
                    ),
                    onPressed: isClockOutDisabled
                        ? null
                        : () {
                            if (controller.clockInDateTime.value != null) {
                              final elapsedSeconds = DateTime.now().difference(controller.clockInDateTime.value!).inSeconds;
                              if (elapsedSeconds < 120) {
                                final remainingSec = 120 - elapsedSeconds;
                                final remainingMin = (remainingSec / 60).ceil();
                                App.showSnackBar(
                                  title: 'Please Wait',
                                  message: 'Please wait $remainingMin minute(s) before Clock Out.',
                                  isError: true,
                                );
                                return;
                              }
                            }
                            controller.openScannerIfLocationEnabled('clock_out');
                          },
                    icon: Icon(
                      hasClockedOut ? Icons.check_circle_rounded : Icons.qr_code_scanner_rounded,
                      size: 18,
                      color: isClockOutDisabled ? const Color(0xFFDC2626) : Colors.white,
                    ),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Clock Out",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isClockOutDisabled ? const Color(0xFFB91C1C) : Colors.white,
                          ),
                        ),
                        if (hasClockedOut) ...[
                          const SizedBox(height: 2),
                          Text(
                            outTime.isNotEmpty ? outTime : "Out Marked",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
