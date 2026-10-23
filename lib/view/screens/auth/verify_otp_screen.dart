import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String whatsappNumber;

  const VerifyOtpScreen({
    super.key,
    required this.whatsappNumber,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // Sirf ek controller aur focus node keyboard flicker rokne ke liye
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ValueNotifier<int> _timerNotifier = ValueNotifier<int>(120);
  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    _timerNotifier.value = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerNotifier.value == 0) {
        timer.cancel();
      } else {
        _timerNotifier.value--;
      }
    });
  }

  String _getTimerText(int start) {
    int minutes = start ~/ 60;
    int seconds = start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    // Screen khulte hi focus aa jaye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerNotifier.dispose();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _otpController.text;
    if (otp.length != 6) {
      App.showSnackBar(
        title: 'Invalid OTP',
        message: 'Please enter the complete 6-digit OTP.',
        isError: true,
      );
      return;
    }

    final AuthController controller = Get.find<AuthController>();
    controller.verifyOtp(widget.whatsappNumber, otp);
  }

  // OTP Box UI
  Widget _buildOtpBox(int index) {
    String char = "";
    if (_otpController.text.length > index) {
      char = _otpController.text[index];
    }

    bool isFocused = _otpController.text.length == index;
    if (index == 5 && _otpController.text.length == 6) isFocused = true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
          width: isFocused ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: App.screenBackgroundColor.first,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'OTP Verification',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Enter the 6-digit code sent to\n${widget.whatsappNumber}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Hidden TextField + Visual OTP Boxes
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0,
                                  child: TextField(
                                    controller: _otpController,
                                    focusNode: _focusNode,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    autofocus: true,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    onChanged: (value) {
                                      setState(() {});
                                      if (value.length == 6) {
                                        FocusScope.of(context).unfocus();
                                        _verifyOtp();
                                      }
                                    },
                                    decoration: const InputDecoration(counterText: ""),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _focusNode.requestFocus(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(6, (index) => Expanded(child: _buildOtpBox(index))),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            ValueListenableBuilder<int>(
                              valueListenable: _timerNotifier,
                              builder: (context, start, child) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          start == 0 ? 'OTP expired ' : 'OTP expire in ',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                        Text(
                                          _getTimerText(start),
                                          style: TextStyle(
                                            color: start == 0 ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (start == 0) ...[
                                      const SizedBox(height: 12),
                                      TextButton(
                                        onPressed: () {
                                          startTimer();
                                          Get.find<AuthController>().sendOtp(navigate: false);
                                        },
                                        child: const Text(
                                          'Resend OTP',
                                          style: TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                            Obx(() {
                              final AuthController controller = Get.find<AuthController>();
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                                    child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
