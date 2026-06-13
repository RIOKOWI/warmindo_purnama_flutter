import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_item_model.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/widgets/order_status_badge.dart';

/// Fake data for skeleton loading
final fakeOrders = List.generate(
  7,
  (i) => OrderModel(
    id: i + 1,
    invoiceNumber: 'INV-2024-${(i + 1).toString().padLeft(5, '0')}',
    userId: 1,
    orderTypeId: 1,
    subtotal: 50000,
    totalAmount: 55000,
    status: 'pending',
    orderItems: [
      const OrderItemModel(
        id: 1,
        orderId: 1,
        productId: 1,
        productName: 'Nasi Goreng',
        quantity: 2,
        productPrice: 25000,
        subtotal: 50000,
      ),
    ],
  ),
);

/// Skeletonizer widget for order list
class OrderListSkeletonizer extends StatelessWidget {
  const OrderListSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeOrders.length,
        itemBuilder: (context, index) {
          final order = fakeOrders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeoCard(
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
                    child: const Icon(Icons.receipt_long, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.invoiceNumber, style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text(
                          '${order.orderItems.length} item · Rp ${currencyFormat.format(order.totalAmount)}',
                          style: AppTextStyles.body.copyWith(color: AppColors.textLight),
                        ),
                        const SizedBox(height: 8),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.text),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}