import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/models/event_scan_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/event_controller.dart';

class EventCheckInScreen extends StatefulWidget {
  final EventPassModel pass;
  final List<EventAttendeeModel> approvedAttendees;

  const EventCheckInScreen({
    super.key,
    required this.pass,
    required this.approvedAttendees,
  });

  @override
  State<EventCheckInScreen> createState() => _EventCheckInScreenState();
}

class _EventCheckInScreenState extends State<EventCheckInScreen> {
  final TextEditingController _gateController = TextEditingController(text: '1');
  final TextEditingController _remarksController =
      TextEditingController(text: 'Verified physical photos at turnstile');

  late List<int> _selectedAttendeeIds;

  @override
  void initState() {
    super.initState();
    _selectedAttendeeIds = widget.approvedAttendees.map((a) => a.id).toList();
  }

  @override
  void dispose() {
    _gateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();
    final pass = widget.pass;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'RECORD GATE ADMISSION',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 17,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Pass Summary Card
                Container(
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.badge_rounded,
                          color: Color(0xFF0284C7),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pass.passNumber,
                              style: const TextStyle(
                                color: Color(0xFF0369A1),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pass ID: ${pass.id} | Status: ${pass.approvalStatus.toUpperCase()}',
                              style: const TextStyle(
                                color: Color(0xFF0284C7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Gate & Remarks Form Card
                Container(
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
                              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_note_rounded, color: Color(0xFF16A34A), size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'GATE & ADMISSION DETAILS',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Gate Name Input Field
                      const Text(
                        'Gate Name / Identifier *',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _gateController,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'e.g. Gate 1 - Main Entrance',
                          prefixIcon: const Icon(Icons.door_sliding_rounded, color: Color(0xFF16A34A), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Remarks Input Field
                      const Text(
                        'Remarks (Optional)',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _remarksController,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'e.g. Verified physical photos at turnstile',
                          prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFF16A34A), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Attendees Selection Card
                if (widget.approvedAttendees.isNotEmpty) ...[
                  Container(
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
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.groups_rounded, color: Color(0xFF10B981), size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'SELECT ATTENDEES FOR ENTRY',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...widget.approvedAttendees.map((att) {
                          final isSelected = _selectedAttendeeIds.contains(att.id);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedAttendeeIds.remove(att.id);
                                } else {
                                  _selectedAttendeeIds.add(att.id);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: const Color(0xFF16A34A),
                                    checkColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFF475569), width: 1.8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          if (!_selectedAttendeeIds.contains(att.id)) {
                                            _selectedAttendeeIds.add(att.id);
                                          }
                                        } else {
                                          _selectedAttendeeIds.remove(att.id);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: att.photoUrl != null && att.photoUrl!.isNotEmpty
                                        ? Image.network(
                                            att.photoUrl!,
                                            width: 38,
                                            height: 38,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                              width: 38,
                                              height: 38,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.person, color: Colors.grey, size: 20),
                                            ),
                                          )
                                        : Container(
                                            width: 38,
                                            height: 38,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.person, color: Colors.grey, size: 20),
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          att.name,
                                          style: const TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${att.personType} | Mob: ${att.mobileNo}',
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),

      // Sticky Fixed Bottom Action Button: SUBMIT ADMISSION
      bottomNavigationBar: Container(
        color: App.screenBackgroundColor.last,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: App.screenBackgroundColor.last,
            child: Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isCheckingIn.value
                      ? null
                      : () async {
                          final res = await controller.performCheckIn(
                            passId: pass.id,
                            attendeeIds: _selectedAttendeeIds,
                            gateName: _gateController.text.trim(),
                            remarks: _remarksController.text.trim(),
                          );
                          if (res != null && res.success) {
                            Get.back(); // Close EventCheckInScreen and return to previous screen
                          }
                        },
                  icon: controller.isCheckingIn.value
                      ? const SizedBox.shrink()
                      : const Icon(Icons.check_circle_rounded, size: 20),
                  label: controller.isCheckingIn.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'SUBMIT ADMISSION',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
