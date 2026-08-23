import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUser();
  }

  void _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error loading profile'),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Log Out'),
                )
              ],
            ),
          );
        }

        final user = snapshot.data!;
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              CircleAvatar(
                radius: 60.r,
                backgroundImage: NetworkImage(user.image),
                backgroundColor: Colors.grey.shade200,
                onBackgroundImageError: (_, __) {},
                child: user.image.isEmpty
                    ? Icon(Icons.person, size: 60.r, color: Colors.grey)
                    : null,
              ),
              SizedBox(height: 24.h),
              Text(
                '${user.firstName} ${user.lastName}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 40.h),
              
              // Profile details card
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildProfileItem(Icons.person_outline, 'Username', user.username),
                      const Divider(),
                      _buildProfileItem(Icons.badge_outlined, 'Gender', user.gender),
                      const Divider(),
                      _buildProfileItem(Icons.badge_outlined, 'ID', user.id.toString()),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 16.w),
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
