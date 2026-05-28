import 'package:flutter/material.dart';
import '../../data/models/table_model.dart';

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
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Tidak ada meja tersedia',
            style: TextStyle(color: Colors.grey),
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
                    onSelect(null); // Unselect
                  } else {
                    onSelect(table);
                  }
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: !isAvailable
                  ? Colors.grey.shade200
                  : isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.white,
            ),
            child: Center(
              child: Text(
                // Extract number from "MEJA 01" -> "01"
                table.tableNumber.replaceAll('MEJA ', ''),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: !isAvailable
                      ? Colors.grey.shade400
                      : isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
