import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/gate_pass_controller.dart';
import 'package:security_manager/models/gate_pass_model.dart';

class GatePassScreen extends StatelessWidget {
  final bool showBackButton;

  const GatePassScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final GatePassController controller = Get.put(GatePassController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        centerTitle: true,
        title: const Text(
          'GATE PASSES',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.8),
        ),
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        leadingWidth: showBackButton ? 70 : 0,
        leading: showBackButton
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
          child: Obx(() {
            if (controller.isLoading.value && controller.gatePasses.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0284C7),
                ),
              );
            }

            if (controller.gatePasses.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchGatePasses(),
                color: const Color(0xFF0284C7),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_late_rounded, size: 60, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 16),
                          const Text('No gate passes found', style: TextStyle(color: Color(0xFF475569), fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchGatePasses(),
              color: const Color(0xFF0284C7),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.gatePasses.length,
                itemBuilder: (context, index) {
                  final pass = controller.gatePasses[index];
                  return _buildPassCard(pass);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPassCard(GatePass pass) {
    Color statusColor = const Color(0xFFD97706);
    Color statusBgColor = const Color(0xFFFFFBEB);
    Color statusBorderColor = const Color(0xFFFDE68A);

    final statusLower = pass.status.toLowerCase();
    if (statusLower == 'approved') {
      statusColor = const Color(0xFF16A34A);
      statusBgColor = const Color(0xFFF0FDF4);
      statusBorderColor = const Color(0xFFBBF7D0);
    } else if (statusLower == 'rejected') {
      statusColor = const Color(0xFFDC2626);
      statusBgColor = const Color(0xFFFEF2F2);
      statusBorderColor = const Color(0xFFFECACA);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Text(
                pass.gatePassNo,
                style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusBorderColor),
                ),
                child: Text(
                  pass.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pass.personName,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${pass.className} - ${pass.sectionName}',
                style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
              ),
              const Spacer(),
              const Icon(Icons.phone_rounded, color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 4),
              Text(pass.contactNo, style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5, fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 20),
          Row(
            children: [
              _buildInfoItem(Icons.calendar_today_rounded, pass.date),
              const SizedBox(width: 20),
              _buildInfoItem(Icons.access_time_rounded, pass.time),
            ],
          ),
          if (pass.reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pass.reason,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 15),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
