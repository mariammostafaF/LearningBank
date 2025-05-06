// File: lib/screens/signup/signup_controller.dart

import 'package:flutter/material.dart'; // Optional: For context if needed
import 'package:firebase_auth/firebase_auth.dart';

/// Enum to represent specific signup result types or errors.
enum SignupResult {
  success,
  passwordMismatch,
  weakPassword, // Example validation
  emailInUse, // Example backend error
  unknownError,
}

/// Handles the business logic for the User Sign Up process.
class SignupController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Attempts to register a new user.
  ///
  /// Takes the necessary user details provided by the view.
  /// Returns a [SignupResult] enum indicating the outcome.
  /// In a real app, this would interact with an Authentication Service
  /// and potentially a User Database/API.
  Future<SignupResult> signup({
    required String username,
    required BuildContext context,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      return SignupResult.passwordMismatch;
    }

    if (password.length < 6) {
      return SignupResult.weakPassword;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return SignupResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return SignupResult.emailInUse;
      } else if (e.code == 'weak-password') {
        return SignupResult.weakPassword;
      } else {
        return SignupResult.unknownError;
      }
    } catch (e) {
      return SignupResult.unknownError;
    }

    // print(
    //     'Attempting signup with Username: $username, Email: $email, Password: [PROTECTED]');

    // // --- Basic Frontend Validation ---
    // if (password != confirmPassword) {
    //   print('Signup Error: Passwords do not match.');
    //   return SignupResult.passwordMismatch;
    // }
    // if (password.length < 6) {
    //    print('Signup Error: Password is too short.');
    //    return SignupResult.weakPassword;
    // }
    // Add more validation: email format, username constraints etc.

    // --- Simulate Network Call/Backend Registration ---
    // Replace this with your actual backend call
    // await Future.delayed(const Duration(seconds: 2));

    // // --- Dummy Success/Failure Logic ---
    // // Replace with actual result checking from your backend
    // // Simulate potential backend errors
    // if (email.toLowerCase() == 'test@taken.com') {
    //    print('Signup Failed: Email already in use.');
    //    return SignupResult.emailInUse;
    // }

    // // Assume success if no specific errors occurred
    // print('Signup Successful!');
    // // Here you might receive back a User object or token from the backend.
    // return SignupResult.success;

    // Catch potential errors during the API call for a generic error
    // try { ... } catch (e) { return SignupResult.unknownError; }
  }

  // You could add methods like:
  // bool validateEmail(String email) { ... }
  // bool validateUsername(String username) { ... }
}
