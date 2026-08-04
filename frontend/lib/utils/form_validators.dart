class FormValidators {
  FormValidators._();

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters.';
    }

    return null;
  }

  static String? requiredName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name.';
    }

    return null;
  }
}
