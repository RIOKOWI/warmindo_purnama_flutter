import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
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
        body: Center(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _screens.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_screens[index], index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const List<_PaymentLogoData> _paymentLogos = [
    _PaymentLogoData('assets/images/payments/qris-logo.svg', 'QRIS'),
    _PaymentLogoData('assets/images/payments/bank-negara-indonesia-(bni)-logo.svg', 'BNI'),
    _PaymentLogoData('assets/images/payments/bank-rakyat-indonesia-(bri)-logo.svg', 'BRI'),
    _PaymentLogoData('assets/images/payments/cimbniaga.png', 'CIMB'),
    _PaymentLogoData('assets/images/payments/bank-permata-logo.svg', 'Permata'),
    _PaymentLogoData('assets/images/payments/maybank.png', 'Maybank'),
    _PaymentLogoData('assets/images/payments/BSS.png', 'BSS'),
    _PaymentLogoData('assets/images/payments/bank-neo-commerce-(bnc)-logo.png', 'BNC'),
    _PaymentLogoData('assets/images/payments/atm-bersama-logo.svg', 'ATM'),
    _PaymentLogoData('assets/images/payments/bank-artha-graha-logo.png', 'Artha'),
  ];

  Widget _buildPaymentLogos() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Text(
          'SUPPORTED BY',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textLight,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: _paymentLogos.map((data) {
            return SizedBox(
              width: 52,
              height: 36,
              child: _PaymentLogo(path: data.path, fallbackText: data.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Lottie.asset(
              data.lottiePath,
              fit: BoxFit.contain,
              repeat: true,
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
          if (index == 2) _buildPaymentLogos(),
        ],
      ),
    );
  }
}

class _PaymentLogoData {
  final String path;
  final String name;
  const _PaymentLogoData(this.path, this.name);
}

class _PaymentLogo extends StatelessWidget {
  final String path;
  final String fallbackText;

  const _PaymentLogo({required this.path, required this.fallbackText});

  @override
  Widget build(BuildContext context) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => _buildFallback(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        fallbackText,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}