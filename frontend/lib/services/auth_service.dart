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

  // ===========================================================
// Delete Account
// Permanently deletes the authenticated Firebase account.
// ===========================================================
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('No authenticated user.');
    }

    await user.delete();
  }

  // ===========================================================
// Reauthenticate
// Confirms the user's password before a sensitive action.
// ===========================================================
  static Future<void> reauthenticate({
    required String password,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      throw StateError('No authenticated user was found.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }
}
