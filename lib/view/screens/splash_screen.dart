import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view/screens/auth/login_screen.dart';
import 'package:security_manager/view/screens/main_screen.dart';
import 'package:security_manager/view_models/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 4), () async {
      String? token = await TokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        AuthController.authToken = token;
        Get.offAll(() => const MainScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double logoSize = (size.width * 0.42).clamp(120.0, 220.0);
    final double titleFontSize = (size.width * 0.052).clamp(18.0, 24.0);
    final double subtitleFontSize = (size.width * 0.032).clamp(11.0, 14.0);

    return Scaffold(
      backgroundColor: App.screenBackgroundColor.first,
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
            // Ambient Decorative Circles
            Positioned(
              top: -size.width * 0.15,
              left: -size.width * 0.15,
              child: Container(
                height: size.width * 0.45,
                width: size.width * 0.45,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.15,
              right: -size.width * 0.15,
              child: Container(
                height: size.width * 0.45,
                width: size.width * 0.45,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 3),
                            SlideTransition(
                              position: _logoAnimation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.asset(
                                          "assets/images/splash_logo.png",
                                          width: logoSize,
                                          height: logoSize,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.security_rounded,
                                            size: logoSize * 0.6,
                                            color: const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Smart AIG - Security Manager',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Administrative Info Group',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: subtitleFontSize,
                                        color: const Color(0xFF475569),
                                        letterSpacing: 5.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(flex: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                width: double.infinity,
                                height: 12,
                                margin: EdgeInsets.symmetric(horizontal: size.width * 0.12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Center(
                                  child: SizedBox(
                                    height: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: LinearProgressIndicator(
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                     color: Colors.green,
                                        backgroundColor: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


