import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_item_model.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/widgets/order_status_badge.dart';

/// Fake data for skeleton loading
final fakeOrder = OrderModel(
  id: 1,
  invoiceNumber: 'INV-2024-00001',
  userId: 1,
  orderTypeId: 1,
  subtotal: 75000,
  totalAmount: 82500,
  status: 'pending',
  notes: null,
  orderItems: const [
    OrderItemModel(
      id: 1,
      orderId: 1,
      productId: 1,
      productName: 'Nasi Goreng',
      quantity: 2,
      productPrice: 25000,
      subtotal: 50000,
    ),
    OrderItemModel(
      id: 2,
      orderId: 1,
      productId: 2,
      productName: 'Es Teh Manis',
      quantity: 2,
      productPrice: 5000,
      subtotal: 10000,
    ),
    OrderItemModel(
      id: 3,
      orderId: 1,
      productId: 3,
      productName: 'Ayam Geprek',
      quantity: 1,
      productPrice: 15000,
      subtotal: 15000,
    ),
  ],
);

/// Skeletonizer widget for order detail
class OrderDetailSkeletonizer extends StatelessWidget {
  const OrderDetailSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Center(child: OrderStatusBadge(status: fakeOrder.status)),
            const SizedBox(height: 16),

            // Order info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipe: Makan di Tempat',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 32),

            // Order items header
            const Text(
              'Item Pesanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Order items list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fakeOrder.orderItems.length,
              itemBuilder: (context, index) {
                return _OrderItemSkeleton(item: fakeOrder.orderItems[index]);
              },
            ),

            const Divider(height: 32),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencyFormat.format(fakeOrder.totalAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemSkeleton extends StatelessWidget {
  final OrderItemModel item;
  const _OrderItemSkeleton({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(item.productName),
      subtitle: Text('${item.quantity}x ${currencyFormat.format(item.productPrice)}'),
      trailing: Text(
        currencyFormat.format(item.subtotal),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}