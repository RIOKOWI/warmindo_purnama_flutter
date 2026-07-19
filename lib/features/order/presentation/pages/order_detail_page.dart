import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/guards/auth_guard.dart';
import '../../../../core/routes/app_router.dart';
import '../../../checkout/data/models/order_model.dart';
import '../../../checkout/data/models/order_item_model.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';

/// Fake data for skeleton loading
final _fakeOrder = OrderModel(
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

/// Page displaying order detail with cancel functionality
class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
    });
  }

  @override
  void dispose() {
    // Clear selected order when leaving the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderProvider>().clearSelectedOrder();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<OrderProvider>(
            builder: (context, provider, _) {
              return Text(provider.selectedOrder?.invoiceNumber ?? 'Detail Pesanan');
            },
          ),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
        body: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchOrderDetail(widget.orderId),
              child: _buildBody(context, provider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderProvider provider) {
    // Error or null state
    final order = provider.isLoadingDetail ? _fakeOrder : provider.selectedOrder;
    if (order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.errorMessage ?? 'Pesanan tidak ditemukan',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchOrderDetail(widget.orderId),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // Main content
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Skeletonizer(
      enabled: provider.isLoadingDetail,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Center(child: OrderStatusBadge(status: order.status)),
            const SizedBox(height: 16),

            // Order info
            _OrderInfo(order: order),
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
              itemCount: order.orderItems.length,
              itemBuilder: (context, index) {
                return _OrderItemTile(item: order.orderItems[index]);
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
                  currencyFormat.format(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Error message
            if (provider.errorMessage != null && !provider.isLoadingDetail) ...[
              Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
            ],

            // Bayar button (only for pending orders with existing payment)
            if (order.status == 'pending' && order.payment != null && !provider.isLoadingDetail) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoadingPayment
                      ? null
                      : () => _onTapBayar(context, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: provider.isLoadingPayment
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Bayar'),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Cancel button (only for pending orders)
            if (order.status == 'pending' && !provider.isLoadingDetail)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.isCancelling
                      ? null
                      : () => _confirmCancel(context, provider),
                  icon: provider.isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: Text(
                    provider.isCancelling ? 'Membatalkan...' : 'Batalkan Pesanan',
                    style: TextStyle(
                      color: provider.isCancelling ? Colors.grey : Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, OrderProvider provider) async {
    // Capture state BEFORE async gap to avoid context issues
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: const Text(
          'Pesanan yang dibatalkan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      navigator.pop();
      await _doCancel(scaffoldMessenger, provider);
    }
  }

  Future<void> _doCancel(ScaffoldMessengerState scaffoldMessenger, OrderProvider provider) async {
    final success = await provider.cancelOrder(widget.orderId);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Pesanan berhasil dibatalkan'
              : provider.errorMessage ?? 'Gagal membatalkan',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _onTapBayar(BuildContext context, OrderModel order) async {
    final paymentId = order.payment?['id'] as int?;
    if (paymentId == null) return;

    final payment = await context.read<OrderProvider>().getExistingPayment(paymentId);
    if (!context.mounted) return;

    if (payment != null) {
      Navigator.pushNamed(
        context,
        AppRouter.payment,
        arguments: PaymentRouteArgs(
          orderId: order.id,
          existingPayment: payment,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<OrderProvider>().errorMessage ?? 'Gagal memuat pembayaran',
          ),
        ),
      );
    }
  }
}

/// Widget displaying order information
class _OrderInfo extends StatelessWidget {
  const _OrderInfo({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final orderTypeName = order.orderTypeId == 1 ? 'Makan di Tempat' : 'Bawa Pulang';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe: $orderTypeName',
          style: const TextStyle(fontSize: 14),
        ),
        if (order.restaurantTableId != null) ...[
          const SizedBox(height: 4),
          Text(
            'Meja: ${order.restaurantTableId}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
        if (order.notes != null && order.notes!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Catatan: ${order.notes}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}

/// Widget displaying individual order item
class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final dynamic item; // OrderItemModel

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