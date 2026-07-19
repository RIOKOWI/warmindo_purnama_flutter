import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/widgets/floating_bottom_navbar.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/pages/home_page.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/pages/cart_page.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/providers/cart_provider.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/pages/order_list_page.dart';
import 'package:warmindo_purnama_flutter/features/profile/presentation/pages/profile_page.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CartPage(),
    OrderListPage(),
    ProfilePage(),
  ];

  List<NavItemData> _buildNavItems(CartProvider cart) => [
    NavItemData(icon: Icons.restaurant_menu, label: 'Menu'),
    NavItemData(
      icon: Icons.shopping_cart,
      label: 'Keranjang',
      badgeCount: cart.totalItemCount,
    ),
    NavItemData(icon: Icons.receipt_long, label: 'Pesanan'),
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