import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/category_manage_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/product_manage_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/table_manage_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/user_manage_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/analytics_page.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/pages/payment_list_page.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/pages/order_list_page.dart';
import 'package:warmindo_purnama_flutter/features/profile/presentation/pages/profile_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    OrderListPage(),
    PaymentListPage(),
    TableManagePage(),
    ProductManagePage(),
    CategoryManagePage(),
    UserManagePage(),
    AnalyticsPage(),
  ];

  final List<NavItemData> _navItems = const [
    NavItemData(icon: Icons.receipt_long, label: 'Order'),
    NavItemData(icon: Icons.payment, label: 'Bayar'),
    NavItemData(icon: Icons.settings, label: 'Kelola Meja'),
    NavItemData(icon: Icons.fastfood, label: 'Produk'),
    NavItemData(icon: Icons.category, label: 'Kategori'),
    NavItemData(icon: Icons.people, label: 'User'),
    NavItemData(icon: Icons.analytics, label: 'Analitik'),
  ];

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_currentIndex].label),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.accent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Warmindo Purnama',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Navigation Items
            _buildNavItem(0, Icons.receipt_long, 'Order'),
            _buildNavItem(1, Icons.payment, 'Bayar'),
            _buildNavItem(2, Icons.settings, 'Kelola Meja'),
            _buildNavItem(3, Icons.fastfood, 'Produk'),
            _buildNavItem(4, Icons.category, 'Kategori'),
            _buildNavItem(5, Icons.people, 'User'),
            _buildNavItem(6, Icons.analytics, 'Analitik'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(
        icon,
        color: _currentIndex == index ? Colors.deepOrange : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: _currentIndex == index ? Colors.deepOrange : null,
          fontWeight: _currentIndex == index ? FontWeight.bold : null,
        ),
      ),
      selected: _currentIndex == index,
      selectedTileColor: Colors.deepOrange.withValues(alpha: 0.1),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

/// Data class untuk navigation item
class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.label,
  });
}