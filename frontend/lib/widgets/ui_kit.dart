import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';


// ===========================================================
// Gradient Button
// The primary action: a pill that floats above the page on a
// coloured glow. Use one per screen at most — a gradient only
// reads as important while it is the only one.
// ===========================================================
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isEnabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: isEnabled ? AppShadows.glow(AppColors.green100) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 58,
              width: double.infinity,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            label,
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// Floating Action Pill
// A wide floating button for a screen's single main action.
// Sits over the content rather than in the layout, so the page
// scrolls underneath it.
// ===========================================================
class FloatingActionPill extends StatelessWidget {
  const FloatingActionPill({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GradientButton(
        label: label,
        icon: icon,
        isLoading: isLoading,
        onPressed: onPressed,
      ),
    );
  }
}

// ===========================================================
// Gradient Surface
// A rounded panel filled with the brand gradient, for the one
// section on a screen that should lead.
// ===========================================================
class GradientSurface extends StatelessWidget {
  const GradientSurface({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.glow(AppColors.blue100),
      ),
      child: child,
    );
  }
}

// ===========================================================
// Soft Card
// The standard white surface: rounded, shadowed, no border.
// ===========================================================
class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: content,
      ),
    );
  }
}



// ===========================================================
// Selectable Chip
// One tappable word.
//
// Shared by the Home check-in card and the Journal check-in
// screen so a selected emotion looks the same in both.
// ===========================================================
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.regular : AppSpacing.large,
            vertical: isCompact ? AppSpacing.small : AppSpacing.medium,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: (isCompact ? AppTextStyles.caption : AppTextStyles.body)
                .copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
