import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/models/active_event_model.dart';
import 'package:security_manager/models/student_search_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/student_search_controller.dart';

class StudentSearchScreen extends StatelessWidget {
  final ActiveEventModel? event;

  const StudentSearchScreen({super.key, this.event});

  @override
  Widget build(BuildContext context) {
    final StudentSearchController controller = Get.put(StudentSearchController());

    if (event != null) {
      controller.initEvent(event!.id);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          event?.title.toUpperCase() ?? 'STUDENT SEARCH',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.8,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          child: Column(
            children: [
              // Search Input Box Header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchTextController,
                    onChanged: (val) => controller.onSearchQueryChanged(val),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by student name, admission no, phone...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13.5,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFEC4899),
                        size: 20,
                      ),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                            onPressed: () => controller.clearSearch(),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Total Count Subheader
              Obx(() {
                if (controller.searchQuery.value.trim().isNotEmpty && controller.students.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Students: ${controller.totalCount.value}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Main Body Content
              Expanded(
                child: Obx(() {
                  final currentQuery = controller.searchQuery.value.trim();

                  // 1. Initial State: Empty search box
                  if (currentQuery.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              size: 44,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Search Students',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Type student name, admission no or phone to search',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // 2. Loading State
                  if (controller.isLoading.value && controller.students.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEC4899),
                      ),
                    );
                  }

                  // 3. Error State
                  if (controller.hasError.value && controller.students.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchStudents(
                        eventId: event?.id ?? controller.eventId ?? 0,
                        query: currentQuery,
                        isUserRefresh: true,
                      ),
                      color: const Color(0xFFEC4899),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: Color(0xFFDC2626),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    controller.errorMessage.value.isNotEmpty
                                        ? controller.errorMessage.value
                                        : 'Failed to search students',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => controller.fetchStudents(
                                      eventId: event?.id ?? controller.eventId ?? 0,
                                      query: currentQuery,
                                      isUserRefresh: true,
                                    ),
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('Try Again'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEC4899),
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

                  final students = controller.students;

                  // 4. Empty Results State
                  if (students.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchStudents(
                        eventId: event?.id ?? controller.eventId ?? 0,
                        query: currentQuery,
                        isUserRefresh: true,
                      ),
                      color: const Color(0xFFEC4899),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
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
                                    Icons.person_search_rounded,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No students found for "$currentQuery"',
                                  style: const TextStyle(
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

                  // 5. Data List State
                  return RefreshIndicator(
                    onRefresh: () => controller.fetchStudents(
                      eventId: event?.id ?? controller.eventId ?? 0,
                      query: currentQuery,
                      isUserRefresh: true,
                    ),
                    color: const Color(0xFFEC4899),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _buildStudentCard(context, student);
                      },
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

  Widget _buildStudentCard(BuildContext context, StudentSearchModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 54,
                height: 54,
                color: const Color(0xFFF1F5F9),
                child: student.studentPhotoUrl != null && student.studentPhotoUrl!.isNotEmpty
                    ? Image.network(
                        student.studentPhotoUrl!,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(student.studentName),
                      )
                    : _buildInitialsAvatar(student.studentName),
              ),
            ),
            const SizedBox(width: 12),

            // Student Info Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Student Name & Pass Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          student.studentName,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: student.passExists ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: student.passExists ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Text(
                          student.passExists ? 'Pass Created' : 'No Pass',
                          style: TextStyle(
                            color: student.passExists ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Class, Section & Roll No
                  Row(
                    children: [
                      Text(
                        'Class: ${student.className} (${student.sectionName})',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Roll: ${student.rollNo}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Adm No & Unique ID
                  Text(
                    'Adm No: ${student.admissionNumber} | ID: ${student.studentUniqueId}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                  ),

                  if (student.fatherName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Father: ${student.fatherName} (${student.fatherMobile.isNotEmpty ? student.fatherMobile : 'N/A'})',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    String initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
