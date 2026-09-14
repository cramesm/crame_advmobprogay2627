import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _userDataFuture = _userService.getUserData();
  }

  void _refreshData() {
    setState(() {
      _loadUserData();
    });
  }

  void _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  // --- Dialog: Update Username ---
  void _showUpdateUsernameDialog(String currentUsername) {
    final controller = TextEditingController(text: currentUsername);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Update Username'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'New Username',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            validator: (value) =>
                (value == null || value.trim().length < 3) ? 'At least 3 characters' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await _userService.updateUsername(username: controller.text.trim());
                _refreshData();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username updated successfully!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update username: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- Dialog: Change Password ---
  void _showChangePasswordDialog(String email) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter current password' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) =>
                    (value == null || value.length < 6) ? 'At least 6 characters' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await _userService.resetPasswordFromCurrentPassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                  email: email,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update password: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // --- Dialog: Delete Account ---
  void _showDeleteAccountDialog(String email) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action is irreversible. Please enter your password to confirm deletion.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await _userService.deleteAccount(
                  email: email,
                  password: passwordController.text,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully.')),
                );
                Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete account: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
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
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Log Out'),
                )
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final String loginType = data['loginType'] ?? 'dummyJson';
        final bool isFirebase = loginType == 'firebase';

        final String username = data['username'] ?? '';
        final String email = data['email'] ?? '';
        final String firstName = data['firstName'] ?? '';
        final String lastName = data['lastName'] ?? '';
        final String image = data['image'] ?? '';
        final String displayName = (firstName.isNotEmpty || lastName.isNotEmpty)
            ? '$firstName $lastName'.trim()
            : username;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 12.h),

              // Avatar
              CircleAvatar(
                radius: 54.r,
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                backgroundColor: primaryColor.withOpacity(0.12),
                onBackgroundImageError: (_, __) {},
                child: image.isEmpty
                    ? Icon(Icons.person, size: 54.r, color: primaryColor)
                    : null,
              ),
              SizedBox(height: 16.h),

              // Name
              Text(
                displayName.isNotEmpty ? displayName : 'User Profile',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),

              // Email
              Text(
                email.isNotEmpty ? email : 'No email attached',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 10.h),

              // Login Type Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isFirebase ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isFirebase ? Colors.orange.shade300 : Colors.blue.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFirebase ? Icons.local_fire_department : Icons.api,
                      size: 16.sp,
                      color: isFirebase ? Colors.orange.shade800 : Colors.blue.shade800,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      isFirebase ? 'Firebase Authentication' : 'DummyJSON REST API',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isFirebase ? Colors.orange.shade900 : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Account Details Card
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
                      _buildProfileItem(Icons.alternate_email, 'Username', username),
                      const Divider(),
                      if (isFirebase) ...[
                        if (data['contactNo'] != null && data['contactNo'].toString().isNotEmpty) ...[
                          _buildProfileItem(Icons.phone_outlined, 'Contact No', data['contactNo'].toString()),
                          const Divider(),
                        ],
                        if (data['age'] != null && data['age'] != 0) ...[
                          _buildProfileItem(Icons.cake_outlined, 'Age', data['age'].toString()),
                          const Divider(),
                        ],
                        _buildProfileItem(Icons.fingerprint, 'Firebase UID',
                            data['uid']?.toString().isNotEmpty == true
                                ? '${data['uid'].toString().substring(0, 10)}...'
                                : 'N/A'),
                      ] else ...[
                        _buildProfileItem(Icons.badge_outlined, 'Gender', data['gender'] ?? 'N/A'),
                        const Divider(),
                        _buildProfileItem(Icons.tag, 'User ID', data['id']?.toString() ?? '0'),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Account Management Card (Update Username, Change Password, Delete Account)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account Management',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.edit_outlined, color: primaryColor),
                      title: const Text('Update Username'),
                      subtitle: Text(
                        isFirebase ? 'Change your display name' : 'Available on Firebase Auth',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      enabled: isFirebase,
                      onTap: isFirebase ? () => _showUpdateUsernameDialog(username) : null,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.lock_reset_outlined, color: primaryColor),
                      title: const Text('Change Password'),
                      subtitle: Text(
                        isFirebase ? 'Reset your Firebase password' : 'Available on Firebase Auth',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      enabled: isFirebase,
                      onTap: isFirebase ? () => _showChangePasswordDialog(email) : null,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                      subtitle: Text(
                        isFirebase ? 'Permanently delete your account' : 'Available on Firebase Auth',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      enabled: isFirebase,
                      onTap: isFirebase ? () => _showDeleteAccountDialog(email) : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
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
              SizedBox(height: 24.h),
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
          Icon(icon, size: 22.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 14.w),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
