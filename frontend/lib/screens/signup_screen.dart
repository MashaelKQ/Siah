import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/auth_error_messages.dart';
import '../utils/form_validators.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/siah_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // ===========================================================
  // Form and Input Controllers
  // Manage validation and values entered by the user.
  // ===========================================================
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ===========================================================
  // Screen State
  // Controls password visibility, terms acceptance, and loading.
  // ===========================================================
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ===========================================================
  // Account Creation
  // Validates the form and creates an account through AuthService.
  // AuthGate automatically opens the main application.
  // ===========================================================
  Future<void> _createAccount() async {
    if (_isLoading) return;

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    if (!_acceptedTerms) {
      SnackbarHelper.show(
        context,
        'Please accept the Terms and Privacy Policy.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.createAccount(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        AuthErrorMessages.signUp(error.code),
      );
    } catch (_) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===========================================================
                // Application Branding
                // Displays the Siah identity during registration.
                // ===========================================================
                const Center(
                  child: SiahLogo(
                    height: 90,
                  ),
                ),

                const SizedBox(height: AppSpacing.large),

                // ===========================================================
                // Registration Introduction
                // Introduces the account creation process.
                // ===========================================================
                const Text(
                  'Create Your Account',
                  style: AppTextStyles.heading1,
                ),

                const SizedBox(height: AppSpacing.small),

                const Text(
                  'Join Siah and begin building healthier daily habits.',
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: AppSpacing.large),

                // ===========================================================
                // Full Name
                // Collects the name displayed in the application.
                // ===========================================================
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: FormValidators.requiredName,
                ),

                const SizedBox(height: AppSpacing.medium),

                // ===========================================================
                // Email Address
                // Collects the email used to access the account.
                // ===========================================================
                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: FormValidators.email,
                ),

                const SizedBox(height: AppSpacing.medium),

                // ===========================================================
                // Password
                // Collects the password used to protect the account.
                // ===========================================================
                TextFormField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip:
                          _obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: FormValidators.password,
                ),

                const SizedBox(height: AppSpacing.medium),

                // ===========================================================
                // Confirm Password
                // Confirms that both entered passwords are identical.
                // ===========================================================
                TextFormField(
                  controller: _confirmPasswordController,
                  enabled: !_isLoading,
                  obscureText: _obscureConfirmPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _createAccount(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Enter your password again',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirmPassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password.';
                    }

                    if (value != _passwordController.text) {
                      return 'The passwords do not match.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.medium),

                // ===========================================================
                // Terms Agreement
                // Records acceptance of the required policies.
                // ===========================================================
                CheckboxListTile(
                  value: _acceptedTerms,
                  enabled: !_isLoading,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I agree to the Terms and Privacy Policy.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.medium),

                // ===========================================================
                // Create Account
                // Submits registration details through AuthService.
                // ===========================================================
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _createAccount,
                    child: _isLoading
                        ? const LoadingIndicator()
                        : const Text('Create Account'),
                  ),
                ),

                const SizedBox(height: AppSpacing.medium),

                // ===========================================================
                // Existing Account
                // Returns existing users to the sign-in screen.
                // ===========================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
