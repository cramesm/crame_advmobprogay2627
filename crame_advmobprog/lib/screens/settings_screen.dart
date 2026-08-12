import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 3: Settings Screen for Application Configuration & Preferences
// Holds app settings, specifically moving the Dark/Light Mode switch here.

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // ENHANCEMENT 3: ThemeProvider State Listener
    // Listens to real-time theme updates from ThemeProvider.

    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          CustomText(
            text: 'Appearance',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          SizedBox(height: 8.h),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                
                // ENHANCEMENT 3: Dark / Light Mode Toggle Switch
                // Renders a SwitchListTile to toggle between Dark and Light mode.

                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                    color: themeProvider.isDark ? Colors.amber : Colors.indigo,
                  ),
                  title: CustomText(
                    text: 'Dark Mode',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle: CustomText(
                    text: themeProvider.isDark
                        ? 'Dark theme is currently active'
                        : 'Light theme is currently active',
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                  value: themeProvider.isDark,
                  onChanged: (bool isDark) {
                    // ENHANCEMENT 3: Trigger theme state change in ThemeProvider
                    themeProvider.setDarkTheme(isDark);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


