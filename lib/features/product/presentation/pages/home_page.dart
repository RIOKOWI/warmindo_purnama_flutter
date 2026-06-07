import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/providers/cart_provider.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/providers/product_provider.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/widgets/category_filter_widget.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/widgets/product_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(
        title: 'MENU',
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRouter.cart),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dark, width: 2),
                    ),
                    child: const Icon(Icons.shopping_cart, color: AppColors.text),
                  ),
                  if (cart.totalItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.totalItemCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.orderList),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dark, width: 2),
              ),
              child: const Icon(Icons.receipt_long, color: AppColors.text),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => auth.logout(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dark, width: 2),
              ),
              child: const Icon(Icons.logout, color: AppColors.text),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          const CategoryFilterWidget(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: const ProductGrid(),
            ),
          ),
        ],
      ),
    );
  }
}