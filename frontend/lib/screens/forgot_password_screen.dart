import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/form_validators.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  // ===========================================================
  // Send Reset Link
  // Asks Firebase to email a password reset link.
  //
  // The same confirmation is shown whether or not an account
  // exists, so the screen never reveals who is registered.
  // ===========================================================
  Future<void> _sendResetLink() async {
    if (_isLoading) return;

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.sendPasswordReset(
        email: _emailController.text,
      );

      if (!mounted) return;

      setState(() {
        _emailSent = true;
      });
    } catch (_) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'The link could not be sent. Check your connection and try again.',
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
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: _emailSent ? _buildConfirmation() : _buildForm(),
        ),
      ),
    );
  }

  // ===========================================================
  // Reset Form
  // Collects the email address that receives the reset link.
  // ===========================================================
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Forgot your password?',
            style: AppTextStyles.heading1,
          ),

          const SizedBox(height: AppSpacing.small),

          const Text(
            'Enter your email address and we will send you a link to '
            'create a new password.',
            style: AppTextStyles.body,
          ),

          const SizedBox(height: AppSpacing.large),

          TextFormField(
            controller: _emailController,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetLink(),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: FormValidators.email,
          ),

          const SizedBox(height: AppSpacing.large),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _sendResetLink,
              child: _isLoading
                  ? const LoadingIndicator()
                  : const Text('Send Reset Link'),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // Confirmation
  // Shown after the reset link has been requested.
  // ===========================================================
  Widget _buildConfirmation() {
    final email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 56,
        ),

        const SizedBox(height: AppSpacing.medium),

        const Text(
          'Check your email',
          style: AppTextStyles.heading1,
        ),

        const SizedBox(height: AppSpacing.small),

        Text(
          'If an account exists for $email, a reset link is on its way. '
          'The link expires after one hour.',
          style: AppTextStyles.body,
        ),

        const SizedBox(height: AppSpacing.medium),

        const Text(
          'No email after a few minutes? Check your spam folder.',
          style: AppTextStyles.caption,
        ),

        const SizedBox(height: AppSpacing.large),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back to Sign In'),
          ),
        ),

        const SizedBox(height: AppSpacing.small),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              setState(() {
                _emailSent = false;
              });
            },
            child: const Text('Use a different email'),
          ),
        ),
      ],
    );
  }
}
