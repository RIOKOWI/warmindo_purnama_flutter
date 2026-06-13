import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';

/// Fake data for skeleton loading
final fakeProducts = List.generate(
  7,
  (i) => ProductModel(
    id: i,
    name: 'Produk ${i + 1}',
    description: 'Deskripsi produk',
    price: 25000,
    stock: 10,
    imageUrl: '',
    category: const CategoryModel(id: 1, name: 'Makanan'),
  ),
);

/// Skeletonizer widget for product list
class ProductManageSkeletonizer extends StatelessWidget {
  const ProductManageSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeProducts.length,
        itemBuilder: (context, index) {
          final product = fakeProducts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProductAdminTileSkeleton(product: product),
          );
        },
      ),
    );
  }
}

class _ProductAdminTileSkeleton extends StatelessWidget {
  final ProductModel product;
  const _ProductAdminTileSkeleton({required this.product});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dark, width: 2),
            ),
            child: const Icon(Icons.fastfood, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text('${product.category.name} · Rp 25.000',
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Stok: ${product.stock}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info, width: 2),
            ),
            child: const Icon(Icons.edit, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error, width: 2),
            ),
            child: const Icon(Icons.delete, color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }
}