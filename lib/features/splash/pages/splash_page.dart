import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';

class SplashPage extends StatelessWidget {
  final VoidCallback? onTap;

  const SplashPage({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dark, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.dark,
                      offset: Offset(8, 8),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/warmindo-icon.jpeg',
                  width: 60,
                  height: 60,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'WARMINDO',
                style: AppTextStyles.display.copyWith(
                  letterSpacing: 4,
                ),
              ),
              Text(
                'PURNAMA',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}