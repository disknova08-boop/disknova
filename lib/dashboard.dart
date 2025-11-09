import 'package:disknova_project/brand_profile_screen.dart';
import 'package:disknova_project/security_screen.dart';
import 'package:disknova_project/utilis/common_widget.dart';
import 'package:disknova_project/utilis/responsive_utilis.dart';
import 'package:disknova_project/verification.dart';
import 'package:disknova_project/video_upload.dart';
import 'package:flutter/material.dart';

import 'analytics_screen.dart';
import 'billing_info.dart';
import 'demo.dart';
import 'file_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AnalyticsScreen(),
    const VideoUploadsScreen(),
    const FileManagerScreen(),
    const BrandProfileScreen(),
    const SocialLinksVerificationScreen(),
    const BillingScreen(),
    const SecuritySettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          if (!Responsive.isMobile(context))
            Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      drawer: Responsive.isMobile(context)
          ? Drawer(
        child: Sidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          },
        ),
      )
          : null,
    );
  }
}