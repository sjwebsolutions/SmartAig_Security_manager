import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/visitor_controller.dart';

class VisitorCheckInScreen extends StatefulWidget {
  const VisitorCheckInScreen({super.key});

  @override
  State<VisitorCheckInScreen> createState() => _VisitorCheckInScreenState();
}

class _VisitorCheckInScreenState extends State<VisitorCheckInScreen> with WidgetsBindingObserver {
  late final VisitorController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.find<VisitorController>();
    // Auto-fetch GPS location silently in the background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCurrentLocation();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-fetch location when user returns from settings
      controller.fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: App.screenBackgroundColor.first,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'VISITOR CHECK-IN',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.8,
          ),
        ),
        backgroundColor: App.appBarBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        leadingWidth: 56,
        leading: Padding(
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  // 1. Visitor Type Dropdown
                  Obx(() => _buildDropdownField(
                    label: 'Visitor Type *',
                    value: controller.selectedVisitorType.value,
                    items: controller.visitorTypes,
                    onChanged: (val) {
                      if (val != null) controller.selectedVisitorType.value = val;
                    },
                  )),
                  const SizedBox(height: 18),

                  // 2. Visitor Name
                  _buildTextField(
                    controller: controller.nameController,
                    label: 'Visitor Name *',
                    hint: 'Enter full name',
                    prefixWidget: const Icon(Icons.person_outline_rounded, color: Color(0xFF0284C7), size: 20),
                  ),
                  const SizedBox(height: 18),

                  // 3. Mobile Number
                  _buildTextField(
                    controller: controller.mobileController,
                    label: 'Mobile Number * (10 Digits)',
                    hint: '9876543210',
                    prefixWidget: const Icon(Icons.phone_android_rounded, color: Color(0xFF0284C7), size: 20),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (val) {
                      if (controller.isSameAsMobile.value) {
                        controller.whatsappController.text = val;
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Checkbox: Same as Mobile Number
                  Obx(() => Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: controller.isSameAsMobile.value,
                          activeColor: const Color(0xFF0284C7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => controller.toggleSameAsMobile(val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.toggleSameAsMobile(!controller.isSameAsMobile.value),
                          child: const Text(
                            'WhatsApp number same as mobile number',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 14),

                  // 4. WhatsApp Number with FontAwesome WhatsApp Icon
                  _buildTextField(
                    controller: controller.whatsappController,
                    label: 'WhatsApp Number * (10 Digits)',
                    hint: '9876543210',
                    prefixWidget: const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Color(0xFF25D366),
                      size: 20,
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 5. Visit Type Dropdown
                  Obx(() => _buildDropdownField(
                    label: 'Visit Type *',
                    value: controller.selectedVisitType.value,
                    items: controller.visitTypes,
                    onChanged: (val) {
                      if (val != null) controller.selectedVisitType.value = val;
                    },
                  )),
                  const SizedBox(height: 18),

                  // 6. Purpose of Visit
                  _buildTextField(
                    controller: controller.purposeController,
                    label: 'Purpose of Visit *',
                    hint: 'e.g. Maintenance work in library',
                    prefixWidget: const Icon(Icons.notes_rounded, color: Color(0xFF0284C7), size: 20),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 28),

                  // 7. Submit Button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              final success = await controller.createVisitor();
                              if (success) {
                                Get.back();
                                App.showSnackBar(
                                  title: 'Success',
                                  message: 'Visitor check-in entry created successfully.',
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF16A34A).withValues(alpha: 0.3),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 20),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Complete Check-In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 12,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7), size: 24),
                selectedItemBuilder: (BuildContext context) {
                  return items.map((String item) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                items: items.map((item) {
                  final isSelected = item.toLowerCase() == value.toLowerCase();
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF334155),
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Widget prefixWidget,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
            prefixIcon: prefixWidget,
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
