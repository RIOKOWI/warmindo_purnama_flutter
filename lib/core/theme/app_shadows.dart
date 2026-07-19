import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Neo Brutalism shadow system
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        const BoxShadow(
          color: AppColors.dark,
          offset: Offset(6, 6),
          blurRadius: 0,
        ),
      ];

  static List<BoxShadow> get button => [
        const BoxShadow(
          color: AppColors.dark,
          offset: Offset(5, 5),
          blurRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.dark.withValues(alpha: 0.15),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> get bottomNav => [
        BoxShadow(
          color: AppColors.dark.withValues(alpha: 0.2),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];
}
