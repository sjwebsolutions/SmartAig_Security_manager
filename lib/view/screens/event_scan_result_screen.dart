import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/models/event_scan_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view/screens/event_check_in_screen.dart';
import 'package:security_manager/view_models/event_controller.dart';

class EventScanResultScreen extends StatelessWidget {
  final EventPassScanResponseModel scanResult;

  const EventScanResultScreen({
    super.key,
    required this.scanResult,
  });



  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();
    final bool isWarning = scanResult.isAlreadyCheckedIn || scanResult.warning.isNotEmpty;
    final passData = scanResult.data;
    final pass = passData?.pass;
    final event = passData?.event;
    final student = passData?.student;
    final approvedAttendees = passData?.approvedAttendees ?? [];

    final Color statusThemeColor = isWarning
        ? const Color(0xFFDC2626) // Red / Warning
        : const Color(0xFF16A34A); // Green / Success

    final Color statusBgColor = isWarning
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF0FDF4);

    final Color statusBorderColor = isWarning
        ? const Color(0xFFFECACA)
        : const Color(0xFFBBF7D0);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SCAN VERIFICATION',
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
        leadingWidth: 70,
        leading: Padding(
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
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchTodayScans(isUserRefresh: true);
            },
            color: const Color(0xFF5340FF),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. STATUS & WARNING BANNER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusBorderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: statusThemeColor.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusThemeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWarning ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                          color: statusThemeColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWarning ? 'DUPLICATE ENTRY ALERT' : 'PASS VALIDATED SUCCESSFULLY',
                              style: TextStyle(
                                color: statusThemeColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              scanResult.warning.isNotEmpty
                                  ? scanResult.warning
                                  : (scanResult.message.isNotEmpty
                                      ? scanResult.message
                                      : 'Event pass check-in record processed.'),
                              style: TextStyle(
                                color: isWarning ? const Color(0xFF7F1D1D) : const Color(0xFF166534),
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. PASS INFO CARD
                if (pass != null) ...[
                  _buildSectionCard(
                    title: 'PASS INFORMATION',
                    icon: Icons.confirmation_number_rounded,
                    iconColor: const Color(0xFF5340FF),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pass.passNumber,
                                  style: const TextStyle(
                                    color: Color(0xFF5340FF),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFC7D2FE)),
                                  ),
                                  child: Text(
                                    'Pass ID: ${pass.id}',
                                    style: const TextStyle(
                                      color: Color(0xFF4F46E5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isWarning ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isWarning ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: Text(
                                pass.approvalStatus.toUpperCase(),
                                style: TextStyle(
                                  color: isWarning ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFE2E8F0), height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                'Pass ID',
                                '${pass.id}',
                                isBold: true,
                              ),
                            ),
                            Expanded(
                              child: _buildDetailRow(
                                'Check-in Status',
                                pass.checkinStatus.replaceAll('_', ' ').toUpperCase(),
                                isBold: true,
                              ),
                            ),
                            if (pass.firstCheckinAt.isNotEmpty) ...[
                              Expanded(
                                child: _buildDetailRow(
                                  'First Check-in',
                                  pass.firstCheckinAt,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow('Attendees Approved', '${pass.totalAttendeesApproved}'),
                            ),
                            Expanded(
                              child: _buildDetailRow('Checked In', '${pass.totalCheckedIn}'),
                            ),
                            Expanded(
                              child: _buildDetailRow('Remaining', '${pass.totalRemaining}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 3. STUDENT DETAILS CARD
                if (student != null) ...[
                  _buildSectionCard(
                    title: 'STUDENT DETAILS',
                    icon: Icons.school_rounded,
                    iconColor: const Color(0xFF0284C7),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: student.photoUrl != null && student.photoUrl!.isNotEmpty
                                    ? Image.network(
                                        student.photoUrl!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.person_rounded,
                                          size: 32,
                                          color: Color(0xFF0284C7),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        size: 32,
                                        color: Color(0xFF0284C7),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.studentName,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Class: ${student.classSection}',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Admission No: ${student.admissionNumber} ${student.rollNo.isNotEmpty ? '| Roll No: ${student.rollNo}' : ''}',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFE2E8F0), height: 20),
                        Row(
                          children: [
                            if (student.fatherName.isNotEmpty) ...[
                              Expanded(
                                child: _buildDetailRow('Father Name', '${student.fatherName}\n(${student.fatherMobile})'),
                              ),
                            ],
                            if (student.motherName.isNotEmpty) ...[
                              Expanded(
                                child: _buildDetailRow('Mother Name', '${student.motherName}\n(${student.motherMobile})'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 4. EVENT DETAILS CARD
                if (event != null) ...[
                  _buildSectionCard(
                    title: 'EVENT INFORMATION',
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFFEA580C),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFFEA580C), size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Venue: ${event.venue}',
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Date: ${event.startDate} - ${event.endDate}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Time: ${event.startTime} - ${event.endTime}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 5. APPROVED ATTENDEES LIST CARD
                if (approvedAttendees.isNotEmpty) ...[
                  _buildSectionCard(
                    title: 'APPROVED ATTENDEES (${approvedAttendees.length})',
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFF10B981),
                    trailing: (pass != null && pass.id > 0)
                        ? SizedBox(
                            height: 32,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                elevation: 1,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Get.to(() => EventCheckInScreen(
                                      pass: pass,
                                      approvedAttendees: approvedAttendees,
                                    ));
                              },
                              icon: const Icon(Icons.how_to_reg_rounded, size: 15),
                              label: const Text(
                                'CHECK-IN PASS',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          )
                        : null,
                    child: Column(
                      children: approvedAttendees.map((att) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.teal.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: att.photoUrl != null && att.photoUrl!.isNotEmpty
                                      ? Image.network(
                                          att.photoUrl!,
                                          width: 46,
                                          height: 46,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.person_rounded,
                                            size: 26,
                                            color: Color(0xFF0D9488),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person_rounded,
                                          size: 26,
                                          color: Color(0xFF0D9488),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      att.name,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${att.personType} | Mob: ${att.mobileNo}',
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (att.maskedAadhaar.isNotEmpty) ...[
                                      Text(
                                        'Aadhaar: ${att.maskedAadhaar}',
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: att.isCheckedIn ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: att.isCheckedIn ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Text(
                                  att.isCheckedIn ? 'Checked In' : 'Pending',
                                  style: TextStyle(
                                    color: att.isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    ),

      // Sticky Fixed Bottom Action Buttons
      bottomNavigationBar: Container(
        color: App.screenBackgroundColor.last,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: App.screenBackgroundColor.last,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5340FF),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
