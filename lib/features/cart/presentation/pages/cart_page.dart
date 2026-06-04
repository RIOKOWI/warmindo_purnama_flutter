import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/routes/app_router.dart';
import '../providers/cart_provider.dart';

/// Cart page displaying shopping cart items
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
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: const Text('Kosongkan'),
            ),
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (cart.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cart.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CartProvider>().fetchCart(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (cart.items.isEmpty) {
      return const Center(
        child: Text('Keranjang kosong'),
      );
    }

    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (_, i) => _CartItemTile(item: cart.items[i]),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kosongkan keranjang?'),
        content: const Text('Semua item akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartProvider>().clearCart();
            },
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }
}

/// Individual cart item tile widget
class _CartItemTile extends StatelessWidget {
  final dynamic item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final currencyFormat = NumberFormat('#,###');

    return ListTile(
      leading: item.product.imageUrl.isNotEmpty
          ? Image.network(
              item.product.imageUrl,
              width: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
            )
          : const Icon(Icons.fastfood),
      title: Text(item.product.name),
      subtitle: Text('Rp ${currencyFormat.format(item.product.price)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => cart.updateQuantity(
              cartItemId: item.cartItemId,
              newQuantity: item.quantity - 1,
            ),
          ),
          Text('${item.quantity}'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: item.quantity < item.product.stock
                ? () => cart.updateQuantity(
                      cartItemId: item.cartItemId,
                      newQuantity: item.quantity + 1,
                    )
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => cart.removeItem(item.cartItemId),
          ),
        ],
      ),
    );
  }
}

/// Bottom checkout bar with total and checkout button
class _BottomCheckout extends StatelessWidget {
  final int totalPrice;
  const _BottomCheckout({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total'),
                Text('Rp ${currencyFormat.format(totalPrice)}'),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.checkout),
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}