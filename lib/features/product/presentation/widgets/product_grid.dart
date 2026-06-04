import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_card.dart';

/// Grid view of products with loading, error, and empty states
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    // Loading state
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ProductProvider>().init(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (provider.products.isEmpty) {
      return const Center(
        child: Text('Tidak ada produk'),
      );
    }

    // Grid produk
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: provider.products.length,
      itemBuilder: (_, i) => ProductCard(product: provider.products[i]),
    );
  }
}