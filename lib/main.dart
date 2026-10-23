import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:security_manager/view/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Prevent screenshots and screen recording across the app
  await ScreenProtector.preventScreenshotOn();
  await ScreenProtector.protectDataLeakageWithBlur();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        canvasColor: const Color(0xFF0F2027),
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          surface: Color(0xFF1E3C48),
        ),
      ),
    );
  }
}
