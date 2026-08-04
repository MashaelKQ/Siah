class AuthErrorMessages {
  AuthErrorMessages._();

  static String signIn(String errorCode) {
    return switch (errorCode) {
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account exists for this email.',
      'wrong-password' => 'The password is incorrect.',
      'invalid-credential' => 'The email or password is incorrect.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      _ => 'Unable to sign in. Please try again.',
    };
  }

  static String signUp(String errorCode) {
    return switch (errorCode) {
      'weak-password' => 'The password is too weak.',
      'email-already-in-use' => 'An account already exists for this email.',
      'invalid-email' => 'Please enter a valid email address.',
      'operation-not-allowed' =>
        'Email and password registration is not enabled.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      _ => 'Unable to create your account. Please try again.',
    };
  }
}
