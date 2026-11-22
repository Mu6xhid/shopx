import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final AuthService _authService = AuthService();
  User? get currentUser => _authService.currentUser;

  bool isLoading = false;
  String? errorMessage;

  // Register
  Future<UserModel?> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;

      final credential = await _authService.register(email, password);

      await credential.user?.updateDisplayName(name);

      final user = credential.user;

      if (user == null) return null;

      await user.reload();

      return UserModel.fromFirebase(FirebaseAuth.instance.currentUser!);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isLoading = false;
    }
  }

  // Login
  Future<UserModel?> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;

      final credential = await _authService.login(email, password);

      final user = credential.user;

      if (user == null) return null;

      return UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isLoading = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    try {
      errorMessage = null;

      await _authService.forgotPassword(email);

      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = null;

      final credential = await _authService.signInWithGoogle();
      final user = credential.user;

      if (user == null) return null;

      return UserModel.fromFirebase(user);
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        errorMessage = 'Google sign-in failed. Please try again.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      return null;
    } finally {
      isLoading = false;
    }
  }
}
