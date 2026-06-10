import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/providers/cart_provider.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_type_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:warmindo_purnama_flutter/features/checkout/presentation/widgets/order_type_selector.dart';
import 'package:warmindo_purnama_flutter/features/checkout/presentation/widgets/table_selector.dart';

/// Fake data for skeleton loading
final _fakeOrderTypes = [
  const OrderTypeModel(id: 1, name: 'dine_in'),
  const OrderTypeModel(id: 2, name: 'take_away'),
];

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
      backgroundColor: AppColors.background,
      appBar: const NeoAppBar(title: 'KONFIRMASI PESANAN', showBackButton: true),
      body: _buildBody(checkout),
      bottomNavigationBar: _BottomSubmitBar(
        checkout: checkout,
        onSubmit: () => _handleSubmit(checkout),
      ),
    );
  }

  Widget _buildBody(CheckoutProvider checkout) {
    if (checkout.errorMessage != null && checkout.orderTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(checkout.errorMessage!, style: AppTextStyles.body),
            const SizedBox(height: 16),
            NeoButtonSmall(
              label: 'Coba lagi',
              onPressed: () => checkout.init(),
            ),
          ],
        ),
      );
    }

    final orderTypes = checkout.isLoading && checkout.orderTypes.isEmpty ? _fakeOrderTypes : checkout.orderTypes;

    return Skeletonizer(
      enabled: checkout.isLoading && checkout.orderTypes.isEmpty,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _OrderSummary(),
            Container(
              height: 3,
              color: AppColors.dark,
              margin: const EdgeInsets.symmetric(vertical: 16),
            ),
            Text('TIPE PESANAN', style: AppTextStyles.title),
            const SizedBox(height: 12),
            OrderTypeSelector(
              orderTypes: orderTypes,
              selected: checkout.selectedOrderType,
              onSelect: checkout.selectOrderType,
            ),
            if (checkout.isDineIn) ...[
              const SizedBox(height: 24),
              Text('PILIH MEJA', style: AppTextStyles.title),
              const SizedBox(height: 12),
              TableSelector(
                tables: checkout.availableTables,
                selected: checkout.selectedTable,
                onSelect: checkout.selectTable,
              ),
            ],
            const SizedBox(height: 24),
            Text('CATATAN', style: AppTextStyles.title),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Opsional...',
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.dark, width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.dark, width: 3),
                ),
              ),
              maxLines: 2,
              onChanged: checkout.setNotes,
            ),
            if (checkout.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error, width: 3),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(checkout.errorMessage!,
                          style: AppTextStyles.body.copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(CheckoutProvider checkout) async {
    final success = await checkout.submitOrder();

    if (!mounted) return;

    if (success) {
      final cart = context.read<CartProvider>();
      final totalAmount = cart.totalPrice;
      cart.clearLocal();
      final orderId = checkout.createdOrder!.id;

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.payment,
          arguments: PaymentRouteArgs(
            orderId: orderId,
            totalAmount: totalAmount,
          ),
        );
      }
      checkout.reset();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkout.errorMessage ?? 'Gagal membuat pesanan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currencyFormat = NumberFormat('#,###');

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RINGKASAN PESANAN', style: AppTextStyles.title),
          const SizedBox(height: 12),
          if (cart.items.isEmpty)
            Text('Tidak ada item', style: AppTextStyles.body)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              itemBuilder: (_, i) {
                final item = cart.items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: AppTextStyles.body),
                            Text('Qty: ${item.quantity}',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${currencyFormat.format(item.subtotal)}',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                );
              },
            ),
          Container(
            height: 2,
            color: AppColors.dark,
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: AppTextStyles.title),
              Text(
                'Rp ${currencyFormat.format(cart.totalPrice)}',
                style: AppTextStyles.headline.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomSubmitBar extends StatelessWidget {
  final CheckoutProvider checkout;
  final VoidCallback onSubmit;

  const _BottomSubmitBar({required this.checkout, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currencyFormat = NumberFormat('#,###');
    final isDineInNoTable = checkout.isDineIn && checkout.selectedTable == null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: const Border(top: BorderSide(color: AppColors.dark, width: 3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDineInNoTable)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Text('Pilih meja terlebih dahulu',
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
                  ],
                ),
              ),
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: AppTextStyles.caption),
                    Text(
                      'Rp ${currencyFormat.format(cart.totalPrice)}',
                      style: AppTextStyles.headline,
                    ),
                  ],
                ),
                const Spacer(),
                NeoButton(
                  label: 'BUAT PESANAN',
                  isLoading: checkout.isSubmitting,
                  onPressed: checkout.canSubmit ? onSubmit : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}