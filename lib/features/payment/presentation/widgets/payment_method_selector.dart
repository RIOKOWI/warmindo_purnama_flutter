import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:warmindo_purnama_flutter/core/constants/payment_constants.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';

/// Widget for selecting payment method
/// VA methods are disabled if amount < 10000
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.amount,
  });

  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod> onSelect;
  final int amount;

  static const List<_PaymentLogoData> _paymentLogos = [
    _PaymentLogoData('images/payments/qris-logo.svg', 'QRIS'),
    _PaymentLogoData('images/payments/bank-negara-indonesia-(bni)-logo.svg', 'BNI'),
    _PaymentLogoData('images/payments/bank-rakyat-indonesia-(bri)-logo.svg', 'BRI'),
    _PaymentLogoData('images/payments/cimbniaga.png', 'CIMB'),
    _PaymentLogoData('images/payments/bank-permata-logo.svg', 'Permata'),
    _PaymentLogoData('images/payments/maybank.png', 'Maybank'),
    _PaymentLogoData('images/payments/BSS.png', 'BSS'),
    _PaymentLogoData('images/payments/bank-neo-commerce-(bnc)-logo.png', 'BNC'),
    _PaymentLogoData('images/payments/atm-bersama-logo.svg', 'ATM'),
    _PaymentLogoData('images/payments/bank-artha-graha-logo.png', 'Artha'),
  ];

  @override
  Widget build(BuildContext context) {
    final minAmount = kMinimumAmountForVa;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: PaymentMethod.values.length,
          itemBuilder: (context, index) {
            final method = PaymentMethod.values[index];
            final isAvailable = method.isAvailableForAmount(amount);
            final isSelected = method == selected;

            return GestureDetector(
              onTap: isAvailable ? () => onSelect(method) : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isAvailable
                        ? (isSelected ? AppColors.accent : AppColors.dark.withValues(alpha: 0.3))
                        : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: isAvailable
                      ? (isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.card)
                      : AppColors.background,
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? (isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.background)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      method.isQris ? Icons.qr_code : Icons.account_balance,
                      color: isAvailable
                          ? (isSelected ? AppColors.accent : AppColors.text)
                          : Colors.grey,
                    ),
                  ),
                  title: Text(
                    method.label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isAvailable
                          ? (isSelected ? AppColors.accent : AppColors.text)
                          : Colors.grey,
                    ),
                  ),
                  subtitle: isAvailable
                      ? (method.isQris
                          ? Text('Semua e-wallet & mobile banking', style: AppTextStyles.caption)
                          : Text('Min. Rp ${minAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.success)))
                      : Text('Min. Rp ${minAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: AppTextStyles.caption.copyWith(color: Colors.grey)),
                  trailing: isAvailable
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.accent : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.accent : AppColors.dark.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        )
                      : Icon(Icons.lock_outline, color: Colors.grey.withValues(alpha: 0.5)),
                  onTap: isAvailable ? () => onSelect(method) : null,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
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