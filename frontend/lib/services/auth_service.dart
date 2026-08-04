import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===========================================================
  // Current User
  // Returns the currently authenticated Firebase user.
  // ===========================================================
  static User? get currentUser => _auth.currentUser;

  // ===========================================================
  // Authentication State
  // Listens for sign-in and sign-out changes.
  // ===========================================================
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===========================================================
  // Create Account
  // Creates a Firebase account and stores the user's display name.
  // ===========================================================
  static Future<UserCredential> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await userCredential.user?.updateDisplayName(
      name.trim(),
    );

    return userCredential;
  }

  // ===========================================================
  // Sign In
  // Authenticates an existing user with email and password.
  // ===========================================================
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ===========================================================
  // Sign Out
  // Ends the current Firebase authentication session.
  // ===========================================================
  static Future<void> signOut() {
    return _auth.signOut();
  }
}
