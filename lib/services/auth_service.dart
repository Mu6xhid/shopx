
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user
  Future<UserCredential> register(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login user
  Future<UserCredential> login(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
