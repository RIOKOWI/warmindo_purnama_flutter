import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/providers/product_provider.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/widgets/product_card.dart';

/// Fake data for skeleton loading
final _fakeProducts = List.generate(
  6,
  (i) => ProductModel(
    id: i + 1,
    name: 'Produk ${i + 1}',
    description: 'Deskripsi produk',
    price: 25000,
    stock: 10,
    imageUrl: '',
    category: const CategoryModel(id: 1, name: 'Makanan'),
  ),
);

/// Grid view of products with loading, error, and empty states
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

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


    final data = provider.isLoading && provider.products.isEmpty ? _fakeProducts : provider.products;

    return Skeletonizer(
      enabled: provider.isLoading && provider.products.isEmpty,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: data.length,
        itemBuilder: (_, i) => ProductCard(product: data[i]),
      ),
    );
  }
}
