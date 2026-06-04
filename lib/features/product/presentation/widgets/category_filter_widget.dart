import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

/// Horizontal scrollable category filter with chips
class CategoryFilterWidget extends StatelessWidget {
  const CategoryFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Chip "Semua" - show all products
          FilterChip(
            label: const Text('Semua'),
            selected: provider.selectedCategoryId == null,
            onSelected: (_) => provider.selectCategory(null),
          ),
          const SizedBox(width: 8),
          // Chips per category
          ...provider.categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat.name),
              selected: provider.selectedCategoryId == cat.id,
              onSelected: (_) => provider.selectCategory(cat.id),
            ),
          )),
        ],
      ),
    );
  }
}