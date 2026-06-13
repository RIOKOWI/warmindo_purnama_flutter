import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/core/guards/auth_guard.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_item_model.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/providers/order_provider.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/widgets/order_status_badge.dart';

/// Fake data for skeleton loading
final _fakeOrders = List.generate(
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

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const NeoAppBar(title: 'PESANAN'),
        body: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchOrders(refresh: true),
              color: AppColors.accent,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                    provider.loadMore();
                  }
                  return false;
                },
                child: _buildBody(provider),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(OrderProvider provider) {
    if (provider.errorMessage != null && provider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!, style: AppTextStyles.body),
            const SizedBox(height: 16),
            NeoButtonSmall(
              label: 'Coba lagi',
              onPressed: () => provider.fetchOrders(refresh: true),
            ),
          ],
        ),
      );
    }

    final data = provider.isLoadingList && provider.orders.isEmpty ? _fakeOrders : provider.orders;

    return Skeletonizer(
      enabled: provider.isLoadingList && provider.orders.isEmpty,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.isEmpty ? 1 : data.length + (provider.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.dark, width: 3),
                      ),
                      child: Icon(Icons.receipt_long,
                          size: 48, color: AppColors.text.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 16),
                    Text('Belum ada pesanan', style: AppTextStyles.headline),
                    const SizedBox(height: 8),
                    Text('Yuk mulai pesan!', style: AppTextStyles.body),
                  ],
                ),
              ),
            );
          }

          if (index == data.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            );
          }

          final order = data[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OrderListTile(order: order),
          );
        },
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  const _OrderListTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

    return NeoCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.orderDetail,
          arguments: order.id,
        );
      },
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
                Text(
                  order.invoiceNumber,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
    );
  }
}