import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:security_manager/models/visitor_model.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/visitor_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitorScreen extends StatelessWidget {
  final bool showBackButton;

  const VisitorScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final VisitorController controller = Get.put(VisitorController());

    void navigateToCheckIn() {
      controller.handleCheckInClick();
    }

    return Scaffold(
      backgroundColor: App.screenBackgroundColor.last,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        centerTitle: true,
        title: const Text(
          'VISITORS LIST',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.8),
        ),
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        leadingWidth: showBackButton ? 56 : 0,
        leading: showBackButton
            ? Padding(
                padding: const EdgeInsets.only(left: 12),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToCheckIn,
        backgroundColor:Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Check-In Visitor',
          style: TextStyle(fontWeight: FontWeight.bold),
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
          child: Obx(() {
            if (controller.isLoading.value && controller.visitors.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0284C7),
                ),
              );
            }

            if (controller.visitors.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchVisitors(),
                color: const Color(0xFF0284C7),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 60, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 16),
                          const Text('No visitors found', style: TextStyle(color: Color(0xFF475569), fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchVisitors(),
              color: const Color(0xFF0284C7),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: controller.visitors.length,
                itemBuilder: (context, index) {
                  final visitor = controller.visitors[index];
                  return _buildVisitorCard(visitor);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildVisitorCard(Visitor visitor) {
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
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: Text(
                        visitor.visitorType.toUpperCase(),
                        style: const TextStyle(color: Color(0xFFEA580C), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (visitor.visitTypeDetail.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Text(
                          visitor.visitTypeDetail.toUpperCase(),
                          style: const TextStyle(color: Color(0xFF0284C7), fontSize: 9, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              if (visitor.isLocationVerified)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded, color: Color(0xFF16A34A), size: 14),
                    SizedBox(width: 4),
                    Text('Verified', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            visitor.name,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              // Mobile Call Action
              InkWell(
                onTap: () async {
                  final cleanNumber = visitor.mobileNo.replaceAll(RegExp(r'\D'), '');
                  if (cleanNumber.isNotEmpty) {
                    final uri = Uri.parse("tel:$cleanNumber");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_rounded, color: Color(0xFF475569), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      visitor.mobileNo,
                      style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // WhatsApp Action with WhatsApp Icon
              InkWell(
                onTap: () async {
                  final cleanNumber = visitor.whatsappNo.replaceAll(RegExp(r'\D'), '');
                  if (cleanNumber.isNotEmpty) {
                    final uri = Uri.parse("https://wa.me/$cleanNumber");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Color(0xFF25D366),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      visitor.whatsappNo,
                      style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 20),
          Row(
            children: [
              Expanded(child: _buildInfoItem(Icons.calendar_today_rounded, visitor.visitDate)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoItem(Icons.access_time_rounded, visitor.visitTime)),
              if (visitor.markedVia.isNotEmpty)
                Text(
                  'Via: ${visitor.markedVia}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
            ],
          ),
          if (visitor.purposeOfVisit.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Purpose: ${visitor.purposeOfVisit}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
          if (visitor.createdBy != null && visitor.createdBy!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Created by: ${visitor.createdBy}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 15),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
