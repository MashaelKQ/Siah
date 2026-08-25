import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

// ===========================================================
// Mood Option
// A shortcut tile.
//
// Unselected tiles are a flat tinted panel with no shadow and
// no border. Only the chosen one lifts and takes colour, so
// the row reads as one quiet surface until you touch it.
// ===========================================================
class MoodOption extends StatelessWidget {
  const MoodOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.regular,
            horizontal: AppSpacing.small,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textPrimary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
