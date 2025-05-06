import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintech/Screens/Dashboard/Dashboard.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Basic input validation (optional but recommended)
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and password cannot be empty')),
        );
        return false;
      }

      // Attempt login
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (context.mounted) {
        // Navigate after successful login
        //Navigator.pushReplacementNamed(context, '/dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        default:
          message = e.message ?? 'Login failed';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      return false;
    } catch (e) {
      print('Unexpected login error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unknown error occurred')),
        );
      }
      return false;
    }
  }
}
