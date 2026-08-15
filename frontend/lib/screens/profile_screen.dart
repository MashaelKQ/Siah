import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/loading_indicator.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDeletingAccount = false;

  // ===========================================================
  // Stored Profile
  // Holds the name and avatar saved in Cloud Firestore.
  // ===========================================================
  AppUser? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ===========================================================
  // Load Profile
  // Reads the stored name and avatar for display.
  // ===========================================================
  Future<void> _loadProfile() async {
    final user = AuthService.currentUser;

    if (user == null) return;

    try {
      final profile = await UserService.getUser(user.uid);

      if (!mounted) return;

      setState(() {
        _profile = profile;
      });
    } catch (_) {
      // The screen still works using the Firebase account details.
    }
  }

  // ===========================================================
  // Open Edit Profile
  // Reloads the profile when changes were saved.
  // ===========================================================
  Future<void> _openEditProfile() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (saved == true) {
      await _loadProfile();
    }
  }

  // ===========================================================
  // Sign Out
  // Ends the current session through AuthService.
  // AuthGate automatically displays the Login screen.
  // ===========================================================
  Future<void> _signOut() async {
    await AuthService.signOut();
  }

  // ===========================================================
  // Delete Confirmation
  // Confirms that the user intends to permanently delete
  // their account.
  // ===========================================================
  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text(
            'This action is permanent and cannot be undone. '
            'Your profile and account will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _requestPassword();
    }
  }

  // ===========================================================
  // Password Confirmation
  // Requests the user's password before account deletion.
  // ===========================================================
  // ===========================================================
// Password Confirmation
// Requests the user's password before account deletion.
// ===========================================================
  Future<void> _requestPassword() async {
    final formKey = GlobalKey<FormState>();

    var enteredPassword = '';
    var obscurePassword = true;

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirm Your Password'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  obscureText: obscurePassword,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip:
                          obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    enteredPassword = value;
                  },
                  onFieldSubmitted: (_) {
                    final isValid = formKey.currentState?.validate() ?? false;

                    if (!isValid) return;

                    Navigator.pop(
                      dialogContext,
                      enteredPassword,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }

                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = formKey.currentState?.validate() ?? false;

                    if (!isValid) return;

                    Navigator.pop(
                      dialogContext,
                      enteredPassword,
                    );
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    if (password != null && mounted) {
      await _deleteAccount(password);
    }
  }

  // ===========================================================
  // Account Deletion
  // Reauthenticates the user, deletes their Firestore profile,
  // and permanently deletes their Firebase Authentication account.
  // ===========================================================
  Future<void> _deleteAccount(String password) async {
    if (_isDeletingAccount) return;

    final user = AuthService.currentUser;

    if (user == null) {
      SnackbarHelper.show(
        context,
        'No signed-in account was found.',
      );
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      // Confirm the user's identity before deleting any data.
      await AuthService.reauthenticate(
        password: password,
      );

      // Delete the Firestore profile while the user is authenticated.
      await UserService.deleteUser(user.uid);

      // Permanently delete the Firebase Authentication account.
      await AuthService.deleteAccount();

      // AuthGate detects the deleted session and displays Login.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'wrong-password' ||
        'invalid-credential' =>
          'The password you entered is incorrect.',
        'requires-recent-login' => 'Please sign out, sign in again, and retry.',
        'too-many-requests' => 'Too many attempts. Please wait and try again.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        _ => 'Unable to delete your account. Please try again.',
      };

      SnackbarHelper.show(context, message);
    } catch (_) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Unable to delete your account. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.regular),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================================================
              // User Information
              // Displays the authenticated user's profile details.
              // ===========================================================
              Center(
                child: AvatarCircle(
                  avatarId: _profile?.avatarId ?? '',
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              Center(
                child: Text(
                  _profile?.name ?? user?.displayName ?? 'User',
                  style: AppTextStyles.heading1,
                ),
              ),

              const SizedBox(height: AppSpacing.xSmall),

              Center(
                child: Text(
                  user?.email ?? '',
                  style: AppTextStyles.caption,
                ),
              ),

              const SizedBox(height: AppSpacing.large),

              // ===========================================================
              // Account Options
              // Provides access to profile and application settings.
              // ===========================================================
              const Text(
                'Account',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: AppSpacing.medium),

              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Personal Information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isDeletingAccount ? null : _openEditProfile,
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Privacy and Security'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Siah'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(),

              // ===========================================================
              // Delete Account
              // Permanently removes the user's profile and account.
              // ===========================================================
              ListTile(
                enabled: !_isDeletingAccount,
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: _confirmDeleteAccount,
              ),

              const Spacer(),

              // ===========================================================
              // Sign Out
              // Signs the current user out through AuthService.
              // ===========================================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isDeletingAccount ? null : _signOut,
                  icon: _isDeletingAccount
                      ? const LoadingIndicator()
                      : const Icon(Icons.logout),
                  label: Text(
                    _isDeletingAccount ? 'Deleting Account...' : 'Sign Out',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
