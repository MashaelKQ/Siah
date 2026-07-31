import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.color,
    super.key,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.regular),
        child: child,
      ),
    );
  }
}
