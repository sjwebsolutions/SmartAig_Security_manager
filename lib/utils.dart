import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  static List<Color> screenBackgroundColor = const [
    Color(0xFFDDEBFF),
    Color(0xFFF7F9FF),
  ];

  static Color get appBarBackgroundColor => const Color(0xFFDDEBFF);

  static void showSnackBar({
    required String title,
    required String message,
    bool isError = false,
    bool isWarning = false,
    Color? backgroundColor,
  }) {
    Color bg = const Color(0xFF16A34A); // Green
    IconData iconData = Icons.check_circle_outline_rounded;

    if (backgroundColor != null) {
      bg = backgroundColor;
    } else if (isError) {
      bg = const Color(0xFFDC2626); // Red
      iconData = Icons.error_outline_rounded;
    } else if (isWarning) {
      bg = const Color(0xFFD97706); // Orange
      iconData = Icons.info_outline_rounded;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        iconData,
        color: Colors.white,
      ),
      shouldIconPulse: true,
    );
  }
}

class TokenManager {
  static const String _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
