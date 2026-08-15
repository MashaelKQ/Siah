import 'package:flutter/material.dart';

import '../data/profile_avatars.dart';
import '../theme/app_colors.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    required this.avatarId,
    this.radius = 44,
    super.key,
  });

  final String avatarId;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final avatar = avatarForId(avatarId);

    return CircleAvatar(
      radius: radius,
      backgroundColor: avatar.color,
      child: Icon(
        avatar.icon,
        size: radius,
        color: AppColors.textPrimary,
      ),
    );
  }
}
