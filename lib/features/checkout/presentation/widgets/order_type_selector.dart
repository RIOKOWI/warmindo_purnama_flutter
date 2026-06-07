import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_type_model.dart';

/// Widget for selecting order type (dine_in or take_away)
class OrderTypeSelector extends StatelessWidget {
  const OrderTypeSelector({
    super.key,
    required this.orderTypes,
    required this.selected,
    required this.onSelect,
  });

  final List<OrderTypeModel> orderTypes;
  final OrderTypeModel? selected;
  final ValueChanged<OrderTypeModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: orderTypes.map((type) {
        final isSelected = selected?.id == type.id;
        final isDineIn = type.isDineIn;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.dark,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: AppColors.dark,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDineIn ? Icons.restaurant : Icons.shopping_bag,
                    size: 32,
                    color: isSelected ? Colors.white : AppColors.text,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isDineIn ? 'Makan di Tempat' : 'Bawa Pulang',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}