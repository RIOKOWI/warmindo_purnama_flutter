import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/cart/data/models/cart_item_model.dart';

/// Fake data for skeleton loading
final fakeCartItems = List.generate(
  5,
  (i) => CartItem(
    cartItemId: i + 1,
    quantity: i + 1,
    product: CartProduct(
      id: i + 1,
      name: 'Produk ${i + 1}',
      price: 25000,
      imageUrl: '',
      stock: 10,
    ),
  ),
);

/// Skeletonizer widget for cart item list
class CartSkeletonizer extends StatelessWidget {
  const CartSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeCartItems.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CartItemSkeleton(item: fakeCartItems[i]),
        ),
      ),
    );
  }
}

class _CartItemSkeleton extends StatelessWidget {
  final CartItem item;
  const _CartItemSkeleton({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

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
                Text(item.product.name, style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(
                  'Rp ${currencyFormat.format(item.product.price)}',
                  style: AppTextStyles.body.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButtonSkeleton(),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text('${item.quantity}', style: AppTextStyles.title),
              ),
              _QuantityButtonSkeleton(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error, width: 2),
                ),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButtonSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.dark,
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.add,
        size: 18,
        color: AppColors.text,
      ),
    );
  }
}