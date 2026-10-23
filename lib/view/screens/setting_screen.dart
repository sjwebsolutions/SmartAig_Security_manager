import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:security_manager/api_service/app_update_service.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';
import 'package:security_manager/view_models/dashboard_controller.dart';
import 'package:security_manager/view/screens/auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${info.version} (${info.buildNumber})';
        });
      }
    } catch (_) {}
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
              onPressed: () {
                Navigator.of(ctx).pop();
                _performLogout();
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

  void _performLogout() async {
    AuthController.authToken = '';
    await TokenManager.clearToken();
    App.showSnackBar(
      title: 'Success',
      message: 'You have been logged out successfully',
    );
    Get.offAll(() => const LoginScreen());
  }

  void _showSupportDialog(BuildContext context, DashboardController controller) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7))),
    );

    try {
      await controller.fetchSupportData();
      if (context.mounted) Navigator.of(context).pop(); // Close loader

      if (controller.supportData.value != null) {
        final data = controller.supportData.value!;
        if (context.mounted) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.4),
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, color: Color(0xFF0284C7)),
                    SizedBox(width: 12),
                    Text(
                      'Contact Support',
                      style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSupportDetail(
                        Icons.business_rounded,
                        "Company",
                        data.name,
                        onTap: () {},
                      ),
                      _buildSupportDetail(
                        Icons.phone_rounded,
                        "Mobile",
                        data.mobile,
                        onTap: () async => await launchUrl(Uri.parse("tel:${data.mobile}"), mode: LaunchMode.externalApplication),
                      ),
                      _buildSupportDetail(
                        FontAwesomeIcons.whatsapp,
                        "WhatsApp",
                        data.whatsapp,
                        onTap: () async => await launchUrl(Uri.parse("https://wa.me/${data.whatsapp}"), mode: LaunchMode.externalApplication),
                      ),
                      _buildSupportDetail(
                        Icons.email_rounded,
                        "Email",
                        data.email,
                        onTap: () async => await launchUrl(Uri.parse("mailto:${data.email}"), mode: LaunchMode.externalApplication),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          );
        }
      } else {
        App.showSnackBar(
          title: 'Support Data Unavailable',
          message: 'Could not load contact details. Please try again later.',
          isError: true,
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Close loader
      App.showSnackBar(
        title: 'Error',
        message: 'Something went wrong while fetching support data.',
        isError: true,
      );
    }
  }

  Widget _buildSupportDetail(IconData icon, String label, String value, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        color: const Color(0xFFF8FAFC),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (label != "Company")
                  const Icon(Icons.open_in_new_rounded, color: Color(0xFF94A3B8), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, DashboardController controller, {required bool isPrivacy}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7))),
    );

    try {
      await controller.fetchPolicyData();
      if (context.mounted) Navigator.of(context).pop();

      if (controller.policyData.value != null) {
        final data = controller.policyData.value!;
        if (context.mounted) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.4),
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                title: Row(
                  children: [
                    Icon(
                      isPrivacy ? Icons.privacy_tip_rounded : Icons.description_rounded,
                      color: isPrivacy ? const Color(0xFF0284C7) : const Color(0xFFEA580C),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isPrivacy ? 'Privacy Policy' : 'Terms of Use',
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPrivacy ? "Privacy Policy" : "Terms of Use",
                          style: const TextStyle(color: Color(0xFF0284C7), fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        HtmlWidget(
                          isPrivacy ? data.privacyPolicy : data.termsOfUse,
                          textStyle: const TextStyle(color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      App.showSnackBar(title: 'Error', message: 'Could not load policies.', isError: true);
    }
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF94A3B8),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "SETTINGS",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.8),
        ),
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingItem(
                  icon: Icons.privacy_tip_rounded,
                  iconColor: const Color(0xFF0284C7),
                  title: "Privacy Policy",
                  subtitle: "Read our privacy policy",
                  onTap: () => _showPolicyDialog(context, controller, isPrivacy: true),
                ),
                const SizedBox(height: 12),
                _buildSettingItem(
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFFEA580C),
                  title: "Terms of Use",
                  subtitle: "Read our terms and conditions",
                  onTap: () => _showPolicyDialog(context, controller, isPrivacy: false),
                ),
                const SizedBox(height: 12),
                _buildSettingItem(
                  icon: Icons.headset_mic_rounded,
                  iconColor: const Color(0xFF0D9488),
                  title: "Contact Support",
                  subtitle: "Get help and support for any issues",
                  onTap: () => _showSupportDialog(context, controller),
                ),
                const SizedBox(height: 12),
                _buildSettingItem(
                  icon: Icons.system_update_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  title: "Check for Updates",
                  subtitle: _appVersion.isNotEmpty
                      ? "App Version $_appVersion"
                      : "Check if a new version is available on store",
                  onTap: () => AppUpdateService.checkAndShowUpdateDialog(context, forceShow: true),
                ),
                const SizedBox(height: 12),
                _buildSettingItem(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFDC2626),
                  title: "Logout",
                  subtitle: "Sign out from the application safely",
                  onTap: () => _showLogoutDialog(context),
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
