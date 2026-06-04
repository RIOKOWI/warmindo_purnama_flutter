import 'package:flutter/material.dart';
import '../../../../core/constants/payment_constants.dart';

/// Widget for selecting payment method
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: PaymentMethod.values.length,
      itemBuilder: (context, index) {
        final method = PaymentMethod.values[index];
        final isSelected = method == selected;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.white,
          ),
          child: ListTile(
            leading: Icon(
              method.isQris ? Icons.qr_code : Icons.account_balance,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
            ),
            title: Text(
              method.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade800,
              ),
            ),
            subtitle: method.isQris
                ? const Text('Semua e-wallet & mobile banking')
                : null,
            trailing: Radio<PaymentMethod>(
              value: method,
              groupValue: selected,
              onChanged: (_) => onSelect(method),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            onTap: () => onSelect(method),
          ),
        );
      },
    );
  }
}