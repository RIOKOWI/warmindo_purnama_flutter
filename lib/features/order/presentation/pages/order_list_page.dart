import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/guards/auth_guard.dart';
import '../../../checkout/data/models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';

/// Page displaying list of user's orders with pagination
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      provider.fetchOrders(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrderProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
        body: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchOrders(refresh: true),
              child: _buildBody(provider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(OrderProvider provider) {
    if (provider.isLoadingList && provider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchOrders(refresh: true),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (provider.orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.orders.length + (provider.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.orders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final order = provider.orders[index];
        return _OrderListTile(order: order);
      },
    );
  }
}

/// Individual order tile in the list
class _OrderListTile extends StatelessWidget {
  const _OrderListTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          order.invoiceNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${order.orderItems.length} item · ${currencyFormat.format(order.totalAmount)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            OrderStatusBadge(status: order.status),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.orderDetail,
            arguments: order.id,
          );
        },
      ),
    );
  }
}