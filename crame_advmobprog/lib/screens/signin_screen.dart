import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';

enum AuthMode { dummyJson, firebase }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginIdentifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthMode _authMode = AuthMode.firebase;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchAuthMode(AuthMode mode) {
    setState(() {
      _authMode = mode;
      _loginIdentifierController.clear();
      _passwordController.clear();
    });
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final userService = UserService();
    setState(() => _isLoading = true);

    try {
      if (_authMode == AuthMode.dummyJson) {
        // DummyJSON API Login
        final response = await userService.loginUser(
          _loginIdentifierController.text.trim(),
          _passwordController.text,
        );

        await userService.saveUserData(response, loginType: 'dummyJson');

        if (!mounted) return;
        setState(() => _isLoading = false);

        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      } else {
        // Firebase Authentication Login
        await userService.signIn(
          email: _loginIdentifierController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String errorMessage = e.toString().replaceAll('Exception:', '').trim();
      if (errorMessage.contains('user-not-found') || errorMessage.contains('invalid-credential')) {
        errorMessage = 'Invalid email or password. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $errorMessage'),
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.h),
                      // App Icon
                      Icon(
                        Icons.lock_person,
                        size: 72.w,
                        color: primaryColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Select authentication provider to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Auth Mode Segmented Selector
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchAuthMode(AuthMode.firebase),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: _authMode == AuthMode.firebase
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: _authMode == AuthMode.firebase
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        size: 18.sp,
                                        color: _authMode == AuthMode.firebase
                                            ? Colors.orange.shade800
                                            : Colors.grey,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Firebase Auth',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _authMode == AuthMode.firebase
                                              ? Colors.black87
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _switchAuthMode(AuthMode.dummyJson),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: _authMode == AuthMode.dummyJson
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: _authMode == AuthMode.dummyJson
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.api,
                                        size: 18.sp,
                                        color: _authMode == AuthMode.dummyJson
                                            ? Colors.blue.shade700
                                            : Colors.grey,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'DummyJSON API',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _authMode == AuthMode.dummyJson
                                              ? Colors.black87
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // Identifier Field (Email for Firebase, Username for DummyJSON)
                      TextFormField(
                        controller: _loginIdentifierController,
                        keyboardType: _authMode == AuthMode.firebase
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                        decoration: InputDecoration(
                          labelText: _authMode == AuthMode.firebase ? 'Email Address' : 'Username',
                          hintText: _authMode == AuthMode.firebase
                              ? 'user@example.com'
                              : null,
                          prefixIcon: Icon(_authMode == AuthMode.firebase
                              ? Icons.email_outlined
                              : Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _authMode == AuthMode.firebase
                                ? 'Enter your email'
                                : 'Enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Password Field
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
                        validator: (value) =>
                            (value == null || value.isEmpty) ? 'Enter password' : null,
                      ),
                      SizedBox(height: 28.h),

                      // Login Button
                      SizedBox(
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _authMode == AuthMode.firebase
                                ? 'Sign In with Firebase'
                                : 'Sign In with DummyJSON',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Link to Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final registeredEmail = await Navigator.pushNamed(context, '/signup');
                              if (registeredEmail is String && registeredEmail.isNotEmpty && mounted) {
                                setState(() {
                                  _authMode = AuthMode.firebase;
                                  _loginIdentifierController.text = registeredEmail;
                                  _passwordController.clear();
                                });
                              }
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
