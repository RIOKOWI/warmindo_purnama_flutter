import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(
        title: 'KERANJANG',
        actions: [
          if (cart.items.isNotEmpty)
            GestureDetector(
              onTap: () => _confirmClear(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.dark, width: 2),
                ),
                child: Text('Kosongkan', style: AppTextStyles.caption),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(cart),
      bottomNavigationBar: cart.items.isNotEmpty
          ? _BottomCheckout(totalPrice: cart.totalPrice)
          : null,
    );
  }

  Widget _buildBody(CartProvider cart) {
    if (cart.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (cart.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cart.errorMessage!, style: AppTextStyles.body),
            const SizedBox(height: 16),
            NeoButtonSmall(
              label: 'Coba lagi',
              onPressed: () => context.read<CartProvider>().fetchCart(),
            ),
          ],
        ),
      );
    }

    if (cart.items.isEmpty) {
      return Center(
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
              child: Icon(Icons.shopping_cart_outlined,
                  size: 48, color: AppColors.text.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text('Keranjang kosong', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text('Yuk mulai belanja!', style: AppTextStyles.body),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _CartItemTile(item: cart.items[i]),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.dark, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kosongkan keranjang?', style: AppTextStyles.headline),
              const SizedBox(height: 12),
              Text('Semua item akan dihapus.',
                  style: AppTextStyles.body),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'Batal',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: 'Kosongkan',
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<CartProvider>().clearCart();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
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
            child: item.product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.fastfood, color: AppColors.accent),
                    ),
                  )
                : const Icon(Icons.fastfood, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
              _QuantityButton(
                icon: Icons.remove,
                onTap: () => cart.updateQuantity(
                  cartItemId: item.cartItemId,
                  newQuantity: item.quantity - 1,
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text('${item.quantity}', style: AppTextStyles.title),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: item.quantity < item.product.stock
                    ? () => cart.updateQuantity(
                          cartItemId: item.cartItemId,
                          newQuantity: item.quantity + 1,
                        )
                    : null,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => cart.removeItem(item.cartItemId),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error, width: 2),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.card : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null ? AppColors.dark : AppColors.dark.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.text : AppColors.text.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _BottomCheckout extends StatelessWidget {
  final int totalPrice;
  const _BottomCheckout({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: const Border(
            top: BorderSide(color: AppColors.dark, width: 3),
          ),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: AppTextStyles.caption),
                Text(
                  'Rp ${currencyFormat.format(totalPrice)}',
                  style: AppTextStyles.headline.copyWith(color: AppColors.accent),
                ),
              ],
            ),
            const Spacer(),
            NeoButton(
              label: 'CHECKOUT',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.pushNamed(context, AppRouter.checkout),
            ),
          ],
        ),
      ),
    );
  }
}