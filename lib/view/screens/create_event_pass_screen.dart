import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:security_manager/models/active_event_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/create_event_pass_controller.dart';
import 'package:security_manager/view_models/student_search_controller.dart';

class CreateEventPassScreen extends StatelessWidget {
  const CreateEventPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateEventPassController controller = Get.put(CreateEventPassController());
    final StudentSearchController searchController = Get.put(StudentSearchController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'EVENT CREATE ENTRY',
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1: SELECT EVENT
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderRow(
                              icon: Icons.event_outlined,
                              title: '1. SELECT EVENT',
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              if (controller.isLoadingEvents.value) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(color: Color(0xFF0F172A)),
                                  ),
                                );
                              }

                              if (controller.activeEvents.isEmpty) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Text(
                                    'No active events found.',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                  ),
                                );
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_outlined, color: Color(0xFF0F172A), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<ActiveEventModel>(
                                          value: controller.selectedEvent.value,
                                          borderRadius: BorderRadius.circular(16),
                                          dropdownColor: Colors.white,
                                          isExpanded: true,
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0F172A)),
                                          items: controller.activeEvents.map((event) {
                                            return DropdownMenuItem<ActiveEventModel>(
                                              value: event,
                                              child: Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              controller.selectedEvent.value = val;
                                              searchController.initEvent(val.id);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // SECTION 2: SELECT STUDENT (INLINE SEARCH)
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderRow(
                              icon: Icons.person_add_outlined,
                              title: '2. SELECT STUDENT',
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final student = controller.selectedStudent.value;

                              // Selected Student View
                              if (student != null) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFBBF7D0)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.person_rounded, color: Color(0xFF16A34A), size: 24),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.studentName,
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Class: ${student.className} (${student.sectionName}) | Adm: ${student.admissionNumber}',
                                              style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel_rounded, color: Color(0xFF64748B), size: 20),
                                        onPressed: () {
                                          controller.selectedStudent.value = null;
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Inline Search Input Box
                              if (controller.selectedEvent.value != null && searchController.eventId != controller.selectedEvent.value!.id) {
                                searchController.initEvent(controller.selectedEvent.value!.id);
                              }

                              return Column(
                                children: [
                                  _buildInputBox(
                                    controller: searchController.searchTextController,
                                    labelText: 'Search by student name, admission no, phone...',
                                    prefixIcon: Icons.search_rounded,
                                    onChanged: (val) => searchController.onSearchQueryChanged(val),
                                  ),

                                  // Inline Search Results List
                                  Obx(() {
                                    final query = searchController.searchQuery.value.trim();
                                    if (query.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    if (searchController.isLoading.value) {
                                      return const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Center(child: CircularProgressIndicator(color: Color(0xFF0F172A))),
                                      );
                                    }

                                    if (searchController.students.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'No students found for "$query"',
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                        ),
                                      );
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      constraints: const BoxConstraints(maxHeight: 220),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: searchController.students.length,
                                        separatorBuilder: (ctx, idx) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                        itemBuilder: (context, index) {
                                          final st = searchController.students[index];
                                          return ListTile(
                                            dense: true,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                            leading: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: const Color(0xFFEEF2FF),
                                              child: Text(
                                                st.studentName.isNotEmpty ? st.studentName.substring(0, 1).toUpperCase() : 'S',
                                                style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ),
                                            title: Text(
                                              st.studentName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 13.5),
                                            ),
                                            subtitle: Text(
                                              'Class ${st.className} (${st.sectionName}) | Adm: ${st.admissionNumber}',
                                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                            ),
                                            onTap: () {
                                              controller.selectStudent(st);
                                              searchController.clearSearch();
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // SECTION 3: PASS SETTINGS
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderRow(
                              icon: Icons.tune_rounded,
                              title: '3. PASS SETTINGS',
                            ),
                            const SizedBox(height: 12),

                            // Auto Approve Pass
                            Obx(() => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Auto Approve Pass',
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      Switch(
                                        value: controller.autoApprove.value,
                                        activeTrackColor: const Color(0xFF0F172A),
                                        activeThumbColor: Colors.white,
                                        onChanged: (val) => controller.autoApprove.value = val,
                                      ),
                                    ],
                                  ),
                                )),

                            // Auto Check-in Pass
                            Obx(() => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Auto Check-in Pass',
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      Switch(
                                        value: controller.autoCheckin.value,
                                        activeTrackColor: const Color(0xFF0F172A),
                                        activeThumbColor: Colors.white,
                                        onChanged: (val) => controller.autoCheckin.value = val,
                                      ),
                                    ],
                                  ),
                                )),

                            // Gate Name
                            _buildInputBox(
                              controller: controller.gateNameController,
                              labelText: 'Gate Name',
                              prefixIcon: Icons.door_sliding_outlined,
                            ),

                            const SizedBox(height: 10),

                            // Remarks
                            _buildInputBox(
                              controller: controller.remarksController,
                              labelText: 'Remarks',
                              prefixIcon: Icons.edit_note_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // SECTION 4: ATTENDEES
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              return _buildHeaderRow(
                                icon: Icons.groups_outlined,
                                title: '4. ATTENDEES (${controller.attendees.length} / 2)',
                              );
                            }),
                            const SizedBox(height: 12),

                            Obx(() {
                              return Column(
                                children: List.generate(controller.attendees.length, (index) {
                                  return _buildAttendeeInnerCard(context, controller, index);
                                }),
                              );
                            }),

                            const SizedBox(height: 6),

                            // Add Another Attendee Button
                            OutlinedButton.icon(
                              onPressed: () => controller.addAttendee(),
                              icon: const Icon(Icons.person_add_outlined, size: 18),
                              label: const Text(
                                '+ ADD ANOTHER ATTENDEE (MAX 2)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1D4ED8),
                                side: const BorderSide(color: Color(0xFF1D4ED8), width: 1.2),
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // BOTTOM FIXED BUTTON: CREATE ENTRY
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              final success = await controller.submitIssueWalkInPass();
                              if (success) {
                                Get.back();
                              }
                            },
                      icon: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        controller.isSubmitting.value ? 'CREATING ENTRY...' : 'CREATE ENTRY',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, letterSpacing: 0.8),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendeeInnerCard(BuildContext context, CreateEventPassController controller, int index) {
    final att = controller.attendees[index];
    final nameController = TextEditingController(text: att.name);
    final mobileController = TextEditingController(text: att.mobileNo);
    final whatsappController = TextEditingController(text: att.whatsappNo);
    final aadhaarController = TextEditingController(text: att.aadhaarNumber);

    final isNameLocked = att.isAutoFilled && att.name.trim().isNotEmpty;
    final isMobileLocked = att.isAutoFilled && att.mobileNo.trim().isNotEmpty;
    final isWhatsappLocked = att.isAutoFilled && att.whatsappNo.trim().isNotEmpty;
    final isAadhaarLocked = att.isAutoFilled && att.aadhaarNumber.trim().isNotEmpty;
    final isPhotoLocked = att.isAutoFilled &&
        ((att.photoUrl != null && att.photoUrl!.isNotEmpty) ||
         (att.existingPhotoPath != null && att.existingPhotoPath!.isNotEmpty));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Attendee #${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
                  ),
                  if (att.isAutoFilled) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.badge_rounded, size: 10, color: Color(0xFF16A34A)),
                          SizedBox(width: 3),
                          Text(
                            'Student Record',
                            style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (controller.attendees.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  onPressed: () => controller.removeAttendee(index),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Person Type Dropdown
          _buildInputWrapper(
            prefixIcon: Icons.badge_outlined,
            child: DropdownButtonFormField<String>(
              initialValue: att.personType,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                labelText: 'Person Type *',
                labelStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0F172A)),
              items: const [
                DropdownMenuItem(value: 'father', child: Text('Father')),
                DropdownMenuItem(value: 'mother', child: Text('Mother')),
                DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'guest', child: Text('Guest')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (val) {
                if (val != null) {
                  controller.applyPersonTypeData(index, val);
                }
              },
            ),
          ),

          const SizedBox(height: 10),

          // Full Name
          _buildInputBox(
            controller: nameController,
            onChanged: (val) => att.name = val,
            readOnly: isNameLocked,
            labelText: 'Full Name *',
            prefixIcon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 10),

          // Mobile No (Strictly 10 Digits)
          _buildInputBox(
            controller: mobileController,
            onChanged: (val) => att.mobileNo = val.replaceAll(' ', ''),
            readOnly: isMobileLocked,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            labelText: 'Mobile No (10 Digits) *',
            prefixIcon: Icons.smartphone_outlined,
          ),

          const SizedBox(height: 10),

          // WhatsApp No (Official Green WhatsApp Icon)
          _buildInputBox(
            controller: whatsappController,
            onChanged: (val) => att.whatsappNo = val.replaceAll(' ', ''),
            readOnly: isWhatsappLocked,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            labelText: 'WhatsApp No (10 Digits)',
            prefixWidget: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Color(0xFF25D366),
              size: 20,
            ),
          ),

          const SizedBox(height: 10),

          // Aadhaar No (12 Digits with 4-4-4 spacing format)
          _buildInputBox(
            controller: aadhaarController,
            onChanged: (val) => att.aadhaarNumber = val.replaceAll(' ', ''),
            readOnly: isAadhaarLocked,
            keyboardType: TextInputType.number,
            maxLength: 14,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              AadhaarInputFormatter(),
            ],
            labelText: 'Aadhaar No (12 Digits)',
            prefixIcon: Icons.credit_card_outlined,
          ),

          const SizedBox(height: 12),

          // Photo Capture Section
          Row(
            children: [
              // Photo Preview Box
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: att.photoFilePath != null && att.photoFilePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          File(att.photoFilePath!),
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      )
                    : (att.photoUrl != null && att.photoUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.network(
                              att.photoUrl!,
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined, color: Color(0xFF0F172A), size: 22),
                                  SizedBox(height: 2),
                                  Text('Photo', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                ],
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Color(0xFF0F172A), size: 22),
                              SizedBox(height: 2),
                              Text('Photo', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            ],
                          ),
              ),

              const SizedBox(width: 10),

              // Side-by-Side Camera & Gallery Buttons inside the Card
              Expanded(
                child: isPhotoLocked
                    ? Container(
                        height: 44,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_rounded, size: 14, color: Color(0xFF64748B)),
                            SizedBox(width: 5),
                            Text(
                              'Photo From Student Record',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          // Camera Option
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.pickAttendeePhoto(index, ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined, size: 16),
                              label: const Text(
                                'Camera',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0F172A),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Gallery Option
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.pickAttendeePhoto(index, ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined, size: 16),
                              label: const Text(
                                'Gallery',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0F172A),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeaderRow({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0F172A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputWrapper({required IconData prefixIcon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(prefixIcon, color: const Color(0xFF0F172A), size: 20),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    Widget? prefixWidget,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          if (prefixWidget != null)
            prefixWidget
          else if (prefixIcon != null)
            Icon(prefixIcon, color: const Color(0xFF0F172A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onChanged: onChanged,
              keyboardType: keyboardType,
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: readOnly ? const Color(0xFF475569) : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (readOnly)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }
}

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', '');
    if (text.length > 12) {
      text = text.substring(0, 12);
    }
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
