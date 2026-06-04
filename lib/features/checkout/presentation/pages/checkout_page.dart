import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/order_type_selector.dart';
import '../widgets/table_selector.dart';

/// Checkout page for confirming order and selecting order type/table
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutProvider>().init();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
      ),
      body: _buildBody(checkout),
      bottomNavigationBar: _BottomSubmitBar(
        checkout: checkout,
        onSubmit: () => _handleSubmit(checkout),
      ),
    );
  }

  Widget _buildBody(CheckoutProvider checkout) {
    if (checkout.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (checkout.errorMessage != null && checkout.orderTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(checkout.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => checkout.init(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OrderSummary(),
          const Divider(height: 32),
          const Text(
            'Tipe Pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          OrderTypeSelector(
            orderTypes: checkout.orderTypes,
            selected: checkout.selectedOrderType,
            onSelect: checkout.selectOrderType,
          ),
          if (checkout.isDineIn) ...[
            const SizedBox(height: 24),
            const Text(
              'Pilih Meja',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TableSelector(
              tables: checkout.availableTables,
              selected: checkout.selectedTable,
              onSelect: checkout.selectTable,
            ),
          ],
          const SizedBox(height: 24),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: checkout.setNotes,
          ),
          if (checkout.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              checkout.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSubmit(CheckoutProvider checkout) async {
    final success = await checkout.submitOrder();

    if (!mounted) return;

    if (success) {
      // 1. Clear local cart
      context.read<CartProvider>().clearLocal();

      // 2. Get orderId
      final orderId = checkout.createdOrder!.id;

      // 3. Navigate to payment
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.payment,
          arguments: PaymentRouteArgs(orderId: orderId),
        );
      }

      // 4. Reset checkout state
      checkout.reset();
    } else {
      // Show error SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkout.errorMessage ?? 'Gagal membuat pesanan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Order summary widget showing cart items and total
class _OrderSummary extends StatelessWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currencyFormat = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (cart.items.isEmpty)
          const Text('Tidak ada item di keranjang')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cart.items.length,
            itemBuilder: (_, i) {
              final item = cart.items[i];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.product.name),
                subtitle: Text('Qty: ${item.quantity}'),
                trailing: Text(
                  'Rp ${currencyFormat.format(item.subtotal)}',
                ),
              );
            },
          ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${currencyFormat.format(cart.totalPrice)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom submit bar with total and submit button
class _BottomSubmitBar extends StatelessWidget {
  final CheckoutProvider checkout;
  final VoidCallback onSubmit;

  const _BottomSubmitBar({
    required this.checkout,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currencyFormat = NumberFormat('#,###');
    final isDineInNoTable = checkout.isDineIn && checkout.selectedTable == null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDineInNoTable)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Pilih meja terlebih dahulu',
                  style: TextStyle(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total'),
                    Text(
                      'Rp ${currencyFormat.format(cart.totalPrice)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: checkout.isSubmitting
                      ? null
                      : (!checkout.canSubmit ? null : onSubmit),
                  child: checkout.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Buat Pesanan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
