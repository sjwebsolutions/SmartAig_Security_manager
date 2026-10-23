import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/api_service/auth_service.dart';
import 'package:security_manager/models/auth_model.dart';
import 'package:security_manager/utils.dart';

import '../view/screens/auth/verify_otp_screen.dart';
import '../view/screens/main_screen.dart';

class AuthController extends GetxController {
  static String authToken = '';
  final AuthService _authService = AuthService();

  final whatsappController = TextEditingController();
  final otpController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    whatsappController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> sendOtp({bool navigate = true}) async {
    if (isLoading.value) return;
    final number = whatsappController.text.trim();

    if (number.isEmpty) {
      App.showSnackBar(
        title: 'Error',
        message: 'Please enter your WhatsApp number',
        isError: true,
      );
      return;
    }

    if (number.length < 10) {
      App.showSnackBar(
        title: 'Error',
        message: 'Please enter a valid WhatsApp number',
        isError: true,
      );
      return;
    }

    isLoading.value = true;

    try {
      String deviceUuid = 'uuid-${DateTime.now().millisecondsSinceEpoch}';
      String deviceName = 'Flutter Client';
      String deviceOs = 'Unknown';

      try {
        deviceName = Platform.localHostname;
        if (Platform.isAndroid) {
          deviceOs = 'Android';
        } else if (Platform.isIOS) {
          deviceOs = 'iOS';
        } else if (Platform.isWindows) {
          deviceOs = 'Windows';
        } else if (Platform.isMacOS) {
          deviceOs = 'macOS';
        } else if (Platform.isLinux) {
          deviceOs = 'Linux';
        }
      } catch (_) {
        deviceName = 'Web Client';
        deviceOs = 'Web';
      }

      final request = OtpRequestModel(
        whatsappNumber: number,
        deviceUuid: deviceUuid,
        deviceName: deviceName,
        deviceOs: deviceOs,
      );

      debugPrint('--- OTP Request Sent ---');
      debugPrint('Request Body: ${jsonEncode(request.toJson())}');

      final response = await _authService.requestOtp(request);

      debugPrint('--- OTP Request Response ---');
      debugPrint('Response Status: ${response.success}');
      debugPrint('Response Message: ${response.message}');
      debugPrint('-----------------------------');

      if (response.success) {
        App.showSnackBar(
          title: 'Success',
          message: response.message,
        );
        if (navigate) {
          Get.to(() => VerifyOtpScreen(whatsappNumber: number));
        }
      } else {
        App.showSnackBar(
          title: 'Error',
          message: response.message,
          isError: true,
        );
      }
    } catch (e) {
      App.showSnackBar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String whatsappNumber, String code) async {
    if (isLoading.value) return;
    
    final number = whatsappNumber.trim();
    if (number.isEmpty) {
      App.showSnackBar(
        title: 'Error',
        message: 'Please enter your WhatsApp number',
        isError: true,
      );
      return;
    }

    if (number.length < 10) {
      App.showSnackBar(
        title: 'Error',
        message: 'Please enter a valid WhatsApp number',
        isError: true,
      );
      return;
    }

    if (code.isEmpty) {
      App.showSnackBar(
        title: 'Error',
        message: 'Please enter the OTP verification code',
        isError: true,
      );
      return;
    }

    if (code.length < 6) {
      App.showSnackBar(
        title: 'Error',
        message: 'Please enter a valid 6-digit OTP code',
        isError: true,
      );
      return;
    }

    isLoading.value = true;

    try {
      String deviceUuid = 'uuid-${DateTime.now().millisecondsSinceEpoch}';
      String deviceName = 'Flutter Client';
      String deviceOs = 'Unknown';

      try {
        deviceName = Platform.localHostname;
        if (Platform.isAndroid) {
          deviceOs = 'Android';
        } else if (Platform.isIOS) {
          deviceOs = 'iOS';
        } else if (Platform.isWindows) {
          deviceOs = 'Windows';
        } else if (Platform.isMacOS) {
          deviceOs = 'macOS';
        } else if (Platform.isLinux) {
          deviceOs = 'Linux';
        }
      } catch (_) {
        deviceName = 'Web Client';
        deviceOs = 'Web';
      }

      final request = OtpVerifyRequestModel(
        whatsappNumber: whatsappNumber,
        otpCode: code,
        deviceUuid: deviceUuid,
        deviceName: deviceName,
        deviceOs: deviceOs,
      );

      debugPrint('--- OTP Verification Request Sent ---');
      debugPrint('Request Body: ${jsonEncode(request.toJson())}');

      final response = await _authService.verifyOtp(request);

      debugPrint('--- OTP Verification Response ---');
      debugPrint('Response Status: ${response.success}');
      debugPrint('Response Message: ${response.message}');
      if (response.data != null) {
        debugPrint('Token: ${response.data!.token}');
        debugPrint('Active Session: ${response.data!.activeSession}');
        if (response.data!.gatekeeper != null) {
          final gk = response.data!.gatekeeper!;
          debugPrint('Gatekeeper ID: ${gk.id}');
          debugPrint('Gatekeeper Name: ${gk.name}');
          debugPrint('Gatekeeper Staff Type: ${gk.staffType}');
          debugPrint('Gatekeeper WhatsApp: ${gk.whatsappNumber}');
          debugPrint('Gatekeeper Phone: ${gk.phone}');
          debugPrint('Gatekeeper School ID: ${gk.schoolId}');
          debugPrint('Gatekeeper Unique ID: ${gk.teacherUniqueId}');
          debugPrint('Gatekeeper Gender: ${gk.gender}');
          debugPrint('Gatekeeper Status: ${gk.status}');
          debugPrint('Gatekeeper Image: ${gk.image}');
        }
      }
      debugPrint('---------------------------------');

      if (response.success) {
        authToken = response.data?.token ?? '';
        if (authToken.isNotEmpty) {
          await TokenManager.saveToken(authToken);
        }
        App.showSnackBar(
          title: 'Success',
          message: response.message,
        );
        Get.offAll(() => const MainScreen());
      } else {
        App.showSnackBar(
          title: 'Error',
          message: response.message,
          isError: true,
        );
      }
    } catch (e) {
      App.showSnackBar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
