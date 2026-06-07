import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/splash/data/models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final SecureStorage _secureStorage = SecureStorage();

  final List<OnboardingData> _screens = OnboardingContents.screens;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await _secureStorage.setHasSeenOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextPage,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildSkipHint(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _screens.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_screens[index]);
                  },
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPage < _screens.length - 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.dark, width: 2),
              ),
              child: Text(
                'Tap to continue',
                style: AppTextStyles.caption,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dark, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.dark,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: 24),
          if (_currentPage == _screens.length - 1)
            NeoButton(
              label: 'MULAI',
              width: double.infinity,
              onPressed: _completeOnboarding,
            )
          else
            const SizedBox(height: 56),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _screens.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: _currentPage == index ? 32 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.accent : AppColors.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.dark, width: 2),
          ),
        ),
      ),
    );
  }
}