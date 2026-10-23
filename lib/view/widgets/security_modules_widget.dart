import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/view/screens/gate_pass_screen.dart';
import 'package:security_manager/view/screens/student_attendance_screen.dart';
import 'package:security_manager/view/screens/visitor_screen.dart';

class SecurityModulesWidget extends StatelessWidget {
  const SecurityModulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Section Header matching image
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Security Modules",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double aspectRatio = width < 320 ? 1.05 : (width > 500 ? 1.35 : 1.15);
              return GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: aspectRatio,
                children: [
                  _buildModuleItem(
                    title: 'Gate Pass',
                    icon: Icons.vpn_key_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Get.to(() => const GatePassScreen());
                    },
                  ),
                  _buildModuleItem(
                    title: 'Visitors',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFFEA580C),
                    onTap: () {
                      Get.to(() => const VisitorScreen());
                    },
                  ),
                  _buildModuleItem(
                    title: 'Student Attendance',
                    icon: Icons.how_to_reg_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Get.to(() => const StudentAttendanceScreen());
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
