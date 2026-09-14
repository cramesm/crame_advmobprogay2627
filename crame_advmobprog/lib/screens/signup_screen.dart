import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Optional DummyJSON API call to demonstrate user creation as per dummyjson.com/users
  Future<void> _createDummyJsonUser() async {
    try {
      await http.post(
        Uri.parse('$host/users/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': _fNameController.text.trim(),
          'lastName': _lNameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 18,
          'phone': _contactNoController.text.trim(),
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );
    } catch (_) {
      // DummyJSON /users/add is simulated and may fail if offline; do not block Firebase auth
    }
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userService = UserService();

      // 1. Firebase Authentication User Registration
      final credential = await userService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Update Firebase Display Name with Username
      await userService.updateUsername(
        username: _usernameController.text.trim(),
      );

      // 3. Save profile metadata locally
      await userService.saveFirebaseUserData(
        credential.user,
        username: _usernameController.text.trim(),
        fName: _fNameController.text.trim(),
        lName: _lNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        contactNo: _contactNoController.text.trim(),
      );

      // 4. DummyJSON API call simulation
      await _createDummyJsonUser();

      // Sign out temporarily so the user explicitly signs in on the sign-in page
      await userService.signOutAfterRegistration();

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
        ),
      );

      final registeredEmail = _emailController.text.trim();
      if (Navigator.canPop(context)) {
        Navigator.pop(context, registeredEmail);
      } else {
        Navigator.pushReplacementNamed(context, '/signin');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString().replaceAll('Exception:', '').trim()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Join Nu B-Dex',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Create an account with Firebase Authentication',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // First & Last Name row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fNameController,
                              decoration: _inputDecoration('First Name', Icons.person_outline),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty) ? 'Enter first name' : null,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _lNameController,
                              decoration: _inputDecoration('Last Name', Icons.person_outline),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty) ? 'Enter last name' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Age & Contact Number row
                      Row(
                        children: [
                          SizedBox(
                            width: 100.w,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('Age', Icons.cake_outlined),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Required';
                                final parsed = int.tryParse(value.trim());
                                if (parsed == null || parsed < 1 || parsed > 120) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _contactNoController,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration('Contact No.', Icons.phone_outlined),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Enter contact number';
                                if (value.trim().length < 11) return 'Min 11 digits';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: _inputDecoration('Username', Icons.alternate_email),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter username';
                          if (value.trim().length < 3) return 'At least 3 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Email Address
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Email Address', Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Enter email address';
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_reset),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      SizedBox(height: 28.h),

                      // Sign Up Button
                      SizedBox(
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Already have an account? Sign In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
