import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/models/active_event_model.dart';
import 'package:security_manager/models/event_pass_application_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/event_entry_controller.dart';
import 'package:security_manager/view/screens/create_event_pass_screen.dart';
import 'package:security_manager/view/screens/student_search_screen.dart';

class EventEntryScreen extends StatelessWidget {
  const EventEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventEntryController controller = Get.put(EventEntryController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'EVENTS & PASSES',
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF1D4ED8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF475569),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('View Events'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.confirmation_number_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('View Passes'),
                      ],
                    ),
                  ),
                ],
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
            child: TabBarView(
              children: [
                _buildEventsTab(context, controller),
                _buildPassesTab(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 1: VIEW EVENTS ---
  Widget _buildEventsTab(BuildContext context, EventEntryController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.activeEvents.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFEC4899),
          ),
        );
      }

      if (controller.hasError.value && controller.activeEvents.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchActiveEvents(isUserRefresh: true),
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
                            : 'Failed to load active events',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => controller.fetchActiveEvents(isUserRefresh: true),
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

      final events = controller.activeEvents;

      if (events.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchActiveEvents(isUserRefresh: true),
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
                        Icons.event_busy_rounded,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No active events found',
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
        onRefresh: () => controller.fetchActiveEvents(isUserRefresh: true),
        color: const Color(0xFFEC4899),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(context, event);
          },
        ),
      );
    });
  }

  Widget _buildEventCard(BuildContext context, ActiveEventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => StudentSearchScreen(event: event)),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Width Banner Image (Compact Height)
            if (event.bannerUrl.isNotEmpty) ...[
              Container(
                width: double.infinity,
                height: 110,
                color: const Color(0xFFF8FAFC),
                child: Image.network(
                  event.bannerUrl,
                  width: double.infinity,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported_rounded, color: Color(0xFF94A3B8), size: 28),
                    );
                  },
                ),
              ),
            ],

            // Event Content Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Event Code & Live Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF2F8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFBCFE8)),
                        ),
                        child: Text(
                          event.eventCode,
                          style: const TextStyle(
                            color: Color(0xFFDB2777),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (event.liveTelecast?.isLive == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.live_tv_rounded, color: Color(0xFFDC2626), size: 12),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (event.subTitle != null && event.subTitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.subTitle!,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Venue, Dates & Times
                  if (event.venue.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Color(0xFFEC4899), size: 14),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                  ],

                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF0284C7), size: 13),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${event.startDate} to ${event.endDate}',
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

                  const SizedBox(height: 3),

                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Color(0xFF16A34A), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        '${event.startTime} - ${event.endTime}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Badges
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildTagBadge(
                        'Max Guests: ${event.maxGuestsPerStudent}',
                        const Color(0xFFEEF2FF),
                        const Color(0xFF4F46E5),
                      ),
                      if (event.requiresApproval)
                        _buildTagBadge('Approval Req.', const Color(0xFFFFFBEB), const Color(0xFFD97706)),
                      if (event.requirePhoto)
                        _buildTagBadge('Photo Req.', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
                      if (event.requireAadhaar)
                        _buildTagBadge('Aadhaar Req.', const Color(0xFFF0F9FF), const Color(0xFF0284C7)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: VIEW PASSES ---
  Widget _buildPassesTab(BuildContext context, EventEntryController controller) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateEventPassScreen()),
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: const Icon(Icons.add_card_rounded, size: 18),
        label: const Text(
          'Create Pass',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      body: Obx(() {
        if (controller.isPassLoading.value && controller.passApplications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFEC4899),
            ),
          );
        }

        if (controller.hasPassError.value && controller.passApplications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchPassApplications(isUserRefresh: true),
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
                          controller.passErrorMessage.value.isNotEmpty
                              ? controller.passErrorMessage.value
                              : 'Failed to load pass applications',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchPassApplications(isUserRefresh: true),
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

        final passes = controller.passApplications;

        if (passes.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchPassApplications(isUserRefresh: true),
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
                          Icons.confirmation_number_outlined,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No pass applications found',
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
          onRefresh: () => controller.fetchPassApplications(isUserRefresh: true),
          color: const Color(0xFFEC4899),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: passes.length,
            itemBuilder: (context, index) {
              final pass = passes[index];
              return _buildPassCard(context, pass, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPassCard(BuildContext context, EventPassApplicationModel pass, EventEntryController controller) {
    Color statusBgColor = const Color(0xFFFEF2F2);
    Color statusTextColor = const Color(0xFFDC2626);
    Color statusBorderColor = const Color(0xFFFECACA);

    final statusLower = pass.approvalStatus.toLowerCase();
    if (statusLower == 'approved') {
      statusBgColor = const Color(0xFFF0FDF4);
      statusTextColor = const Color(0xFF16A34A);
      statusBorderColor = const Color(0xFFBBF7D0);
    } else if (statusLower == 'pending') {
      statusBgColor = const Color(0xFFFFFBEB);
      statusTextColor = const Color(0xFFD97706);
      statusBorderColor = const Color(0xFFFDE68A);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row: Pass Number Badge & Approval Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.confirmation_number_rounded,
                        size: 13,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pass.passNumber,
                        style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusBorderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusTextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pass.approvalStatus.toUpperCase(),
                        style: TextStyle(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Student Info Header (Photo/Initials, Name, Adm No, Class, Section)
            if (pass.student != null) ...[
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: pass.student!.photoUrl != null && pass.student!.photoUrl!.isNotEmpty
                          ? Image.network(
                              pass.student!.photoUrl!,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarInitials(pass.student!.name),
                            )
                          : _buildAvatarInitials(pass.student!.name),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pass.student!.name,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Class ${pass.student!.className} (${pass.student!.section})',
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Adm: ${pass.student!.admissionNumber}',
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 8),
            ],

            // Attendees Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_rounded, size: 16, color: Color(0xFF0F172A)),
                    const SizedBox(width: 5),
                    Text(
                      'Attendees (${pass.attendees.length})',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Approved: ${pass.totalAttendeesApproved}/${pass.totalAttendeesRequested}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Attendees List
            if (pass.attendees.isNotEmpty) ...[
              Column(
                children: pass.attendees.map((att) => _buildAttendeeItem(att)).toList(),
              ),
            ],

            const SizedBox(height: 8),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 6),

            // Footer: Timestamp & Action By
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${pass.createdAt}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                ),
                if (pass.actionByName != null && pass.actionByName!.isNotEmpty) ...[
                  Text(
                    'By: ${pass.actionByName}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),

            if (pass.adminRemarks != null && pass.adminRemarks!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Remarks: ${pass.adminRemarks}',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Single Conditional Action Button (Reject if Approved, Approve if Pending/Rejected)
            const SizedBox(height: 10),
            if (statusLower == 'approved') ...[
              SizedBox(
                width: double.infinity,
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () => _showPassStatusDialog(context, controller, pass, 'reject'),
                  icon: const Icon(Icons.cancel_rounded, size: 16),
                  label: const Text(
                    'Reject Pass',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () => _showPassStatusDialog(context, controller, pass, 'approve'),
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: const Text(
                    'Approve Pass',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPassStatusDialog(
    BuildContext context,
    EventEntryController controller,
    EventPassApplicationModel pass,
    String action,
  ) {
    final isApprove = action == 'approve';
    final remarksController = TextEditingController(
      text: isApprove ? 'Approved by Gate In-Charge' : 'Rejected by Gate In-Charge',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isApprove ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
              const SizedBox(width: 8),
              Text(
                isApprove ? 'Approve Pass' : 'Reject Pass',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pass No: ${pass.passNumber}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              if (pass.student != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Student: ${pass.student!.name}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: remarksController,
                decoration: InputDecoration(
                  labelText: 'Remarks / Reason',
                  labelStyle: const TextStyle(color: Color(0xFF64748B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isApprove ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await controller.updatePassStatus(
                  passId: pass.id,
                  action: action,
                  remarks: remarksController.text.trim(),
                );
              },
              icon: Icon(isApprove ? Icons.check_rounded : Icons.close_rounded, size: 18),
              label: Text(isApprove ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendeeItem(PassAttendeeModel att) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFE2E8F0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: att.photoUrl != null && att.photoUrl!.isNotEmpty
                  ? Image.network(
                      att.photoUrl!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildAvatarInitials(att.name, size: 14),
                    )
                  : _buildAvatarInitials(att.name, size: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${att.name} (${att.personType.toUpperCase()})',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (att.isCheckedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF16A34A)),
                            SizedBox(width: 3),
                            Text(
                              'Checked In',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Mobile: ${att.mobileNo.isNotEmpty ? att.mobileNo : 'N/A'}${att.aadhaarMasked != null && att.aadhaarMasked!.isNotEmpty ? ' | Aadhaar: ${att.aadhaarMasked}' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitials(String name, {double size = 18}) {
    String initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P';
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTagBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
