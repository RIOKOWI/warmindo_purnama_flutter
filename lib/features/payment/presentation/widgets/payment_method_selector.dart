import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final minAmount = kMinimumAmountForVa;

    return ListView.builder(
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
    );
  }
}