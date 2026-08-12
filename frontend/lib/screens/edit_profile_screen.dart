import 'package:flutter/material.dart';

import '../data/profile_avatars.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/form_validators.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/loading_indicator.dart';

// ===========================================================
// Edit Profile Screen
// Lets the user change the name and avatar shown in the app.
//
// Returns true when changes were saved, so the Profile screen
// knows to reload.
// ===========================================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedAvatarId = profileAvatars.first.id;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  // ===========================================================
  // Load Profile
  // Fills the form with the user's stored profile.
  // ===========================================================
  Future<void> _loadProfile() async {
    final user = AuthService.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final profile = await UserService.getUser(user.uid);

      if (!mounted) return;

      setState(() {
        _nameController.text = profile?.name ?? user.displayName ?? '';
        _selectedAvatarId = profile?.avatarId.isNotEmpty == true
            ? profile!.avatarId
            : profileAvatars.first.id;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      SnackbarHelper.show(
        context,
        'Your profile could not be loaded. Check your connection.',
      );
    }
  }

  // ===========================================================
  // Save Profile
  // Updates the Firestore profile and the Firebase display name
  // so both stay in step.
  // ===========================================================
  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    final user = AuthService.currentUser;

    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await UserService.updateProfile(
        userId: user.uid,
        name: _nameController.text,
        avatarId: _selectedAvatarId,
      );

      await AuthService.updateDisplayName(_nameController.text);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      SnackbarHelper.show(
        context,
        'Your changes could not be saved. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.regular),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===========================================================
                      // Current Selection
                      // Previews the avatar as it will appear on Profile.
                      // ===========================================================
                      Center(
                        child: AvatarCircle(
                          avatarId: _selectedAvatarId,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.large),

                      // ===========================================================
                      // Display Name
                      // ===========================================================
                      const Text(
                        'Display Name',
                        style: AppTextStyles.title,
                      ),

                      const SizedBox(height: AppSpacing.small),

                      TextFormField(
                        controller: _nameController,
                        enabled: !_isSaving,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: FormValidators.requiredName,
                      ),

                      const SizedBox(height: AppSpacing.large),

                      // ===========================================================
                      // Avatar Choice
                      // ===========================================================
                      const Text(
                        'Avatar',
                        style: AppTextStyles.title,
                      ),

                      const SizedBox(height: AppSpacing.small),

                      const Text(
                        'Pick the icon that represents you.',
                        style: AppTextStyles.caption,
                      ),

                      const SizedBox(height: AppSpacing.medium),

                      Wrap(
                        spacing: AppSpacing.medium,
                        runSpacing: AppSpacing.medium,
                        children: [
                          for (final avatar in profileAvatars)
                            _AvatarChoice(
                              avatar: avatar,
                              isSelected: avatar.id == _selectedAvatarId,
                              onTap: _isSaving
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedAvatarId = avatar.id;
                                      });
                                    },
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xLarge),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const LoadingIndicator()
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ===========================================================
// Avatar Choice
// A single selectable avatar in the picker.
// ===========================================================
class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  final ProfileAvatar avatar;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.green100 : AppColors.border,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: AvatarCircle(
          avatarId: avatar.id,
          radius: 26,
        ),
      ),
    );
  }
}
