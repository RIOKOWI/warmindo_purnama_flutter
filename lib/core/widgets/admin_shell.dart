import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/widgets/floating_bottom_navbar.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/pages/payment_list_page.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/pages/order_list_page.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/pages/home_page.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/pages/cart_page.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/pages/table_status_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/user_manage_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/product_manage_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PaymentListPage(),
    OrderListPage(),
    HomePage(),
    CartPage(),
    TableStatusPage(),
    UserManagePage(),
    ProductManagePage(),
  ];

  final List<NavItemData> _navItems = const [
    NavItemData(icon: Icons.payment, label: 'Bayar'),
    NavItemData(icon: Icons.receipt_long, label: 'Order'),
    NavItemData(icon: Icons.restaurant_menu, label: 'Menu'),
    NavItemData(icon: Icons.shopping_cart, label: 'Cart'),
    NavItemData(icon: Icons.table_restaurant, label: 'Meja'),
    NavItemData(icon: Icons.people, label: 'User'),
    NavItemData(icon: Icons.fastfood, label: 'Produk'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}