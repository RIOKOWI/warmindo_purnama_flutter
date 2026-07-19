import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_radius.dart';

/// Neo Brutalism card with thick border and shadow
class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.dark, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.dark,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Neo Card with custom background
class NeoCardCustom extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const NeoCardCustom({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.dark, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.dark,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}