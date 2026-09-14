import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<UserService> userService = ValueNotifier(UserService());

class UserService {
  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      await saveUserData(data, loginType: 'dummyJson');
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  /// **Save User Data to SharedPreferences**
  /// Save user data from API response based on User model
  Future<void> saveUserData(Map<String, dynamic> userData, {String loginType = 'dummyJson'}) async {
    final prefs = await SharedPreferences.getInstance();
    final user = model.User.fromJson(userData);

    await prefs.setString('loginType', loginType);
    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);

    // Support generic token key if present in API response
    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  /// Save Firebase User metadata and registration profile details to SharedPreferences
  Future<void> saveFirebaseUserData(
    User? fbUser, {
    String? username,
    String? fName,
    String? lName,
    int? age,
    String? contactNo,
  }) async {
    if (fbUser == null) return;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('loginType', 'firebase');
    await prefs.setString('uid', fbUser.uid);
    await prefs.setString('email', fbUser.email ?? '');

    final resolvedUsername = username ?? fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Firebase User';
    await prefs.setString('username', resolvedUsername);

    if (fName != null) await prefs.setString('firstName', fName);
    if (lName != null) await prefs.setString('lastName', lName);
    if (age != null) await prefs.setInt('age', age);
    if (contactNo != null) await prefs.setString('contactNo', contactNo);

    final token = await fbUser.getIdToken() ?? '';
    await prefs.setString('accessToken', token);
    await prefs.setString('token', token);
  }

  /// Retrieve user data dictionary from SharedPreferences & Auth Provider
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final fbUser = firebaseAuth.currentUser;
    final storedLoginType = prefs.getString('loginType');

    final isFirebase = (storedLoginType == 'firebase') || (fbUser != null);

    if (isFirebase) {
      final token = await fbUser?.getIdToken() ?? prefs.getString('accessToken') ?? '';
      return {
        'loginType': 'firebase',
        'uid': fbUser?.uid ?? prefs.getString('uid') ?? '',
        'id': prefs.getInt('id') ?? 1,
        'username': fbUser?.displayName ?? prefs.getString('username') ?? (fbUser?.email?.split('@').first ?? 'User'),
        'email': fbUser?.email ?? prefs.getString('email') ?? '',
        'firstName': prefs.getString('firstName') ?? '',
        'lastName': prefs.getString('lastName') ?? '',
        'age': prefs.getInt('age') ?? 0,
        'contactNo': prefs.getString('contactNo') ?? '',
        'gender': prefs.getString('gender') ?? 'N/A',
        'image': fbUser?.photoURL ?? prefs.getString('image') ?? '',
        'accessToken': token,
        'refreshToken': '',
        'token': token,
      };
    }

    return {
      'loginType': 'dummyJson',
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
    };
  }

  /// Retrieve User model from SharedPreferences
  Future<model.User> getUser() async {
    final userData = await getUserData();
    return model.User.fromJson(userData);
  }

  /// **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    if (firebaseAuth.currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  /// **Logout and Clear User Data**
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await signOut();
      userService.value = UserService();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }

  // Firebase Authentication methods

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await saveFirebaseUserData(credential.user);
    userService.value = this;
    return credential;
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await saveFirebaseUserData(credential.user);
    userService.value = this;
    return credential;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userService.value = this;
  }

  /// Sign out temporarily after registration so that the user explicitly logs in on the sign-in screen
  Future<void> signOutAfterRegistration() async {
    await firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('token');
    userService.value = this;
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    userService.value = this;
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userService.value = UserService();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
