import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/auth_error_messages.dart';
import '../utils/form_validators.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/siah_logo.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ===========================================================
  // Form and Input Controllers
  // Manage validation and values entered by the user.
  // ===========================================================
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ===========================================================
  // Screen State
  // Controls password visibility and login loading state.
  // ===========================================================
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ===========================================================
  // Sign In
  // Validates the form and signs the user in through AuthService.
  // AuthGate automatically opens the main application.
  // ===========================================================
  Future<void> _login() async {
    if (_isLoading) return;

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        AuthErrorMessages.signIn(error.code),
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
                // Displays the Siah identity on the authentication screen.
                // ===========================================================
                const Center(
                  child: SiahLogo(
                    height: 110,
                  ),
                ),

                const SizedBox(height: AppSpacing.large),

                // ===========================================================
                // Login Introduction
                // Welcomes the user and explains the required action.
                // ===========================================================
                const Text(
                  'Welcome Back',
                  style: AppTextStyles.heading1,
                ),

                const SizedBox(height: AppSpacing.small),

                const Text(
                  'Sign in to continue your wellbeing journey.',
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: AppSpacing.large),

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
                // Collects the user's password securely.
                // ===========================================================
                TextFormField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
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

                // ===========================================================
                // Password Recovery
                // Will later connect to Firebase password reset.
                // ===========================================================
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
    ? null
    : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ForgotPasswordScreen(),
          ),
        );
      },
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: AppSpacing.medium),

                // ===========================================================
                // Sign In Action
                // Submits the user's credentials through AuthService.
                // ===========================================================
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const LoadingIndicator()
                        : const Text('Sign In'),
                  ),
                ),

                const SizedBox(height: AppSpacing.large),

                // ===========================================================
                // Account Registration
                // Opens the registration screen for new users.
                // ===========================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Do not have an account?'),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                      child: const Text('Create Account'),
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
