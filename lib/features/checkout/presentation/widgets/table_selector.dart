import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/table_model.dart';

/// Widget for selecting a table (shown when dine_in is selected)
class TableSelector extends StatelessWidget {
  const TableSelector({
    super.key,
    required this.tables,
    this.selected,
    required this.onSelect,
  });

  final List<TableModel> tables;
  final TableModel? selected;
  final ValueChanged<TableModel?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dark, width: 3),
        ),
        child: Center(
          child: Text(
            'Tidak ada meja tersedia',
            style: AppTextStyles.body.copyWith(color: AppColors.textLight),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        final isSelected = selected?.id == table.id;
        final isAvailable = table.isAvailable;

        return GestureDetector(
          onTap: isAvailable
              ? () {
                  if (isSelected) {
                    onSelect(null);
                  } else {
                    onSelect(table);
                  }
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: !isAvailable
                  ? AppColors.background
                  : isSelected
                      ? AppColors.accent
                      : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAvailable ? AppColors.dark : AppColors.dark.withValues(alpha: 0.3),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected && isAvailable
                  ? [
                      const BoxShadow(
                        color: AppColors.dark,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                table.tableNumber.replaceAll('MEJA ', ''),
                style: AppTextStyles.title.copyWith(
                  color: !isAvailable
                      ? AppColors.text.withValues(alpha: 0.3)
                      : isSelected
                          ? Colors.white
                          : AppColors.text,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}