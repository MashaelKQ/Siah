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

  // ===========================================================
  // Password Reset
  // Firebase hides whether an address is registered, so there
  // is deliberately no 'user-not-found' case here: a missing
  // account returns success and simply sends no email.
  // ===========================================================
  static String passwordReset(String errorCode) {
    return switch (errorCode) {
      'invalid-email' => 'Please enter a valid email address.',
      'user-not-found' => 'No account exists for this email.',
      'missing-email' => 'Please enter your email address.',
      'operation-not-allowed' =>
        'Email sign-in is not enabled for this project.',
      'invalid-api-key' || 'app-not-authorized' =>
        'This app is not authorised to use Firebase Authentication.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'too-many-requests' =>
        'Too many attempts. Please wait a few minutes and try again.',
      _ => 'The link could not be sent. Please try again.',
    };
  }
}
