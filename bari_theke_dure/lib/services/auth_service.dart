// lib/services/auth_service.dart
// মেইল ভেরিফিকেশন + চেকিং পুরোপুরি বন্ধ — এখন সরাসরি লগইন হবে

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // ====================== SIGN UP ======================
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;
      if (user == null) return false;

      // শুধু নাম + Firestore-এ ডাটা — কোনো ভেরিফিকেশন মেইল পাঠাবে না
      await Future.wait([
        user.updateDisplayName(name),
        _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email.toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        }),
      ]);

      Get.snackbar(
        "Success",
        "Account created successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = "Sign up failed";
      if (e.code == 'weak-password') {
        msg = "Password is too weak";
      // ignore: curly_braces_in_flow_control_structures
      } else if (e.code == 'email-already-in-use') msg = "Email already exists";
      // ignore: curly_braces_in_flow_control_structures
      else if (e.code == 'invalid-email') msg = "Invalid email";

      Get.snackbar("Error", msg, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar("Error", "Something went wrong", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  // ====================== SIGN IN ======================
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // ভেরিফাইড কি না চেক করব না — সরাসরি লগইন হবে
      Get.snackbar("Success", "Logged in successfully!", backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = "Wrong email or password";
      if (e.code == 'user-not-found') {
        msg = "No user found";
      // ignore: curly_braces_in_flow_control_structures
      } else if (e.code == 'invalid-email') msg = "Invalid email";
      // ignore: curly_braces_in_flow_control_structures
      else if (e.code == 'too-many-requests') msg = "Too many attempts. Try later";

      Get.snackbar("Error", msg, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar("Error", "Network error", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  // ====================== SIGN OUT ======================
  Future<void> signOut() async {
    await _auth.signOut();
  }
}