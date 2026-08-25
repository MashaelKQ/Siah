import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

// ===========================================================
// Activity Card
// A white row with a tinted icon square.
//
// The colour argument tints the icon tile only, so the three
// activities stay distinguishable without any of them turning
// into a block of colour.
// ===========================================================
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.regular),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: AppSpacing.regular),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.small),

              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
