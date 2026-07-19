import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/widgets/floating_bottom_navbar.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/pages/order_list_page.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/pages/home_page.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/pages/cart_page.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/providers/cart_provider.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/pages/payment_list_page.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/pages/table_status_page.dart';
import 'package:warmindo_purnama_flutter/features/profile/presentation/pages/profile_page.dart';

class KasirShell extends StatefulWidget {
  const KasirShell({super.key});

  @override
  State<KasirShell> createState() => _KasirShellState();
}

class _KasirShellState extends State<KasirShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    OrderListPage(),
    HomePage(),
    CartPage(),
    PaymentListPage(),
    TableStatusPage(),
    ProfilePage(),
  ];

  List<NavItemData> _buildNavItems(CartProvider cart) => [
    NavItemData(icon: Icons.receipt_long, label: 'Order'),
    NavItemData(icon: Icons.restaurant_menu, label: 'Menu'),
    NavItemData(
      icon: Icons.shopping_cart,
      label: 'Keranjang',
      badgeCount: cart.totalItemCount,
    ),
    NavItemData(icon: Icons.payment, label: 'Bayar'),
    NavItemData(icon: Icons.table_restaurant, label: 'Meja'),
    NavItemData(icon: Icons.person_pin, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) => FloatingBottomNavBar(
          items: _buildNavItems(cart),
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}