import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/api_service/app_update_service.dart';
import 'package:security_manager/models/dashboard_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view/screens/auth/login_screen.dart';
import 'package:security_manager/view/screens/gate_pass_screen.dart';
import 'package:security_manager/view/screens/setting_screen.dart';
import 'package:security_manager/view/screens/visitor_screen.dart';
import 'package:security_manager/view/widgets/app_shimmer_loader.dart';
import 'package:security_manager/view/widgets/attendance_widget.dart';
import 'package:security_manager/view/widgets/security_modules_widget.dart';
import 'package:security_manager/view_models/auth_controller.dart';
import 'package:security_manager/view_models/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget _buildVerifiedBadge({double size = 18}) {
    return Image.asset(
      'assets/images/blue_tick.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/verified.png',
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.verified_rounded,
              color: const Color(0xFF1DA1F2),
              size: size,
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.checkAndShowUpdateDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Obx(() {
      if (controller.dashboardData.value == null) {
        if (controller.hasError.value && !controller.isLoading.value) {
          return Scaffold(
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
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.red.shade600,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Connection or Server Error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unable to connect to server. Please check your internet connection or try again later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchDashboardData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Refresh',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
        return const AppShimmerLoader();
      }

      final data = controller.dashboardData.value!;

      return Scaffold(
        drawerEnableOpenDragGesture: false,
        drawer: _buildDrawer(context, data),
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A), size: 26),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menu',
            ),
          ),
          title: const Text(
            'SECURITY DASHBOARD',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
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
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchDashboardData(isUserRefresh: true),
              color: Colors.tealAccent.shade700,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile & School Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
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
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.teal.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: data.gatekeeper?.thumbnail != null &&
                                          data.gatekeeper!.thumbnail.isNotEmpty
                                      ? Image.network(
                                          data.gatekeeper!.thumbnail,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.person_rounded, size: 28, color: Colors.teal.shade700),
                                        )
                                      : Icon(Icons.person_rounded, size: 28, color: Colors.teal.shade700),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            (data.gatekeeper?.name == null ||
                                                    data.gatekeeper?.name.toString().toLowerCase().contains('gatekeeper') == true ||
                                                    data.gatekeeper?.name.toString().toLowerCase().contains('gate keeper') == true)
                                                ? 'Security Manager'
                                                : data.gatekeeper!.name,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        _buildVerifiedBadge(size: 18),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Security Manager',
                                      style: TextStyle(
                                        color: Colors.teal.shade700,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE2E8F0), height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.school_rounded, color: Color(0xFF475569), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        data.school?.schoolName ?? 'School',
                                        style: const TextStyle(
                                          color: Color(0xFF334155),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    _buildVerifiedBadge(size: 15),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                'Session: ${data.activeSession}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Statistics Big Card Container
                    Container(
                      padding: const EdgeInsets.all(16.0),
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
                                  Icons.analytics_rounded,
                                  color: Color(0xFF4F46E5),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "TODAY'S STATISTICS",
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double width = constraints.maxWidth;
                              final double aspectRatio = width < 320 ? 2.5 : (width > 500 ? 4.0 : 3.2);
                              return GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: aspectRatio,
                                children: [
                                  _buildStatCard(
                                    title: 'Total Passes',
                                    value: data.statistics?.totalToday ?? 0,
                                    icon: Icons.assignment_rounded,
                                    color: const Color(0xFF0284C7),
                                  ),
                                  _buildStatCard(
                                    title: 'Pending',
                                    value: data.statistics?.pendingToday ?? 0,
                                    icon: Icons.pending_actions_rounded,
                                    color: const Color(0xFFD97706),
                                  ),
                                  _buildStatCard(
                                    title: 'Approved',
                                    value: data.statistics?.approvedToday ?? 0,
                                    icon: Icons.check_circle_rounded,
                                    color: const Color(0xFF16A34A),
                                  ),
                                  _buildStatCard(
                                    title: 'Rejected',
                                    value: data.statistics?.rejectedToday ?? 0,
                                    icon: Icons.cancel_rounded,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Attendance Clock Card (Only Clock In & Clock Out)
                    const AttendanceWidget(),
                    const SizedBox(height: 10),

                    // Security Modules Widget
                    const SecurityModulesWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDrawer(BuildContext context, DashboardData data) {
    return Drawer(
      backgroundColor: const Color(0xFFF1F5F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
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
              // Profile Header Card (White Background, Rounded Radius)
              Container(
                margin: const EdgeInsets.all(14.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: data.gatekeeper?.thumbnail != null &&
                                data.gatekeeper!.thumbnail.isNotEmpty
                            ? Image.network(
                                data.gatekeeper!.thumbnail,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.person_rounded, size: 28, color: Colors.blue.shade700),
                              )
                            : Icon(Icons.person_rounded, size: 28, color: Colors.blue.shade700),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  (data.gatekeeper?.name == null ||
                                          data.gatekeeper?.name.toString().toLowerCase().contains('gatekeeper') == true ||
                                          data.gatekeeper?.name.toString().toLowerCase().contains('gate keeper') == true)
                                      ? 'Security Manager'
                                      : data.gatekeeper!.name,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              _buildVerifiedBadge(size: 16),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  data.school?.schoolName ?? 'School',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              _buildVerifiedBadge(size: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Drawer Menu Items (White Background, Rounded Radius)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                      iconColor: const Color(0xFF0284C7),
                      textColor: const Color(0xFF0F172A),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.vpn_key_rounded,
                      title: 'Gate Pass',
                      iconColor: const Color(0xFF0284C7),
                      textColor: const Color(0xFF0F172A),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const GatePassScreen());
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.people_alt_rounded,
                      title: 'Visitors',
                      iconColor: const Color(0xFFEA580C),
                      textColor: const Color(0xFF0F172A),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const VisitorScreen());
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      iconColor: const Color(0xFF0284C7),
                      textColor: const Color(0xFF0F172A),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const SettingScreen());
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.system_update_rounded,
                      title: 'Check for Updates',
                      iconColor: const Color(0xFF0284C7),
                      textColor: const Color(0xFF0F172A),
                      onTap: () {
                        Navigator.pop(context);
                        AppUpdateService.checkAndShowUpdateDialog(context, forceShow: true);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0284C7),
    Color textColor = const Color(0xFF0F172A),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textColor.withValues(alpha: 0.3),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Text(
                'Confirm Logout',
                style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out from this device?',
            style: TextStyle(color: Color(0xFF475569), fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                AuthController.authToken = '';
                await TokenManager.clearToken();
                App.showSnackBar(
                  title: 'Success',
                  message: 'You have been logged out successfully',
                );
                Get.offAll(() => const LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
