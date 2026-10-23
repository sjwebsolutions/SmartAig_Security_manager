import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:security_manager/utils.dart';
import 'package:security_manager/view/screens/dashboard_screen.dart';
import 'package:security_manager/view/screens/gate_pass_screen.dart';
import 'package:security_manager/view/screens/setting_screen.dart';
import 'package:security_manager/view/screens/visitor_screen.dart';
import 'package:security_manager/view_models/dashboard_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardScreen(),
    GatePassScreen(showBackButton: false),
    VisitorScreen(showBackButton: false),
    SettingScreen(),
  ];

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
        if (index == 0) {
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().fetchDashboardData(isUserRefresh: true);
          }
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? Colors.white : Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final navBarWidget = Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: Platform.isIOS ? 25 : 0,
        top: 10,
      ),
      child: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: Color(0xFF0F265C),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Color(0x260F265C),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildNavItem(
                index: 0,
                label: 'Dashboard',
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard_rounded,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                index: 1,
                label: 'Gate Pass',
                icon: Icons.vpn_key_outlined,
                selectedIcon: Icons.vpn_key_rounded,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                index: 2,
                label: 'Visitor',
                icon: Icons.people_outline_rounded,
                selectedIcon: Icons.people_rounded,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                index: 3,
                label: 'Setting',
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
              ),
            ),
          ],
        ),
      ),
    );

    if (Platform.isAndroid) {
      return SafeArea(
        top: false,
        child: navBarWidget,
      );
    }
    return navBarWidget;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: App.appBarBackgroundColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: App.screenBackgroundColor.last,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: App.screenBackgroundColor.last,
        body: pages[currentIndex],
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}