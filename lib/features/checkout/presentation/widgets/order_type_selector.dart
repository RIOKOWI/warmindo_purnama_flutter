import 'package:flutter/material.dart';
import '../../data/models/order_type_model.dart';

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
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDineIn ? Icons.restaurant : Icons.shopping_bag,
                    size: 32,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isDineIn ? 'Makan di Tempat' : 'Bawa Pulang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade800,
                    ),
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
