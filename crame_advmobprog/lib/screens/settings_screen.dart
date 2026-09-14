import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Settings Screen for Application Configuration, Preferences, and Account Management

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await UserService().logout();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    themeProvider.setDarkTheme(isDark);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Account Settings Section (Logout)
          CustomText(
            text: 'Account',
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
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: CustomText(
                    text: 'Log Out',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                  subtitle: CustomText(
                    text: 'Sign out and return to sign-in screen',
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}