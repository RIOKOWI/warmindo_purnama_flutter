import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/providers/product_provider.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/widgets/product_card.dart';

/// Grid view of products with loading, error, and empty states
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!, style: AppTextStyles.body),
            const SizedBox(height: 16),
            NeoButtonSmall(
              label: 'Coba lagi',
              onPressed: () => context.read<ProductProvider>().init(),
            ),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dark, width: 3),
              ),
              child: Icon(Icons.fastfood,
                  size: 40, color: AppColors.text.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text('Tidak ada produk', style: AppTextStyles.headline),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.products.length,
      itemBuilder: (_, i) => ProductCard(product: provider.products[i]),
    );
  }
}