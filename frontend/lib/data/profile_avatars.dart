import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ===========================================================
// Profile Avatars
// A fixed set of avatars the user can choose from.
//
// Only the id is stored in Firestore, so changing an icon or
// colour here updates every user without a data migration.
// ===========================================================
class ProfileAvatar {
  const ProfileAvatar({
    required this.id,
    required this.icon,
    required this.color,
  });

  final String id;
  final IconData icon;
  final Color color;
}

const List<ProfileAvatar> profileAvatars = [
  ProfileAvatar(
    id: 'leaf',
    icon: Icons.eco_outlined,
    color: AppColors.green40,
  ),
  ProfileAvatar(
    id: 'sun',
    icon: Icons.wb_sunny_outlined,
    color: AppColors.yellow40,
  ),
  ProfileAvatar(
    id: 'wave',
    icon: Icons.waves_outlined,
    color: AppColors.blue40,
  ),
  ProfileAvatar(
    id: 'moon',
    icon: Icons.nightlight_outlined,
    color: AppColors.blue60,
  ),
  ProfileAvatar(
    id: 'flower',
    icon: Icons.local_florist_outlined,
    color: AppColors.green60,
  ),
  ProfileAvatar(
    id: 'star',
    icon: Icons.star_outline,
    color: AppColors.yellow60,
  ),
  ProfileAvatar(
    id: 'cloud',
    icon: Icons.cloud_outlined,
    color: AppColors.blue40,
  ),
  ProfileAvatar(
    id: 'heart',
    icon: Icons.favorite_outline,
    color: AppColors.green40,
  ),
];

// ===========================================================
// Avatar Lookup
// Falls back to the first avatar for empty or unknown ids.
// ===========================================================
ProfileAvatar avatarForId(String id) {
  return profileAvatars.firstWhere(
    (avatar) => avatar.id == id,
    orElse: () => profileAvatars.first,
  );
}
