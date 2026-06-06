import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/pages/cart_page.dart';
import 'package:warmindo_purnama_flutter/features/checkout/presentation/pages/checkout_page.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/pages/order_detail_page.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/pages/order_list_page.dart';
import 'package:warmindo_purnama_flutter/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:warmindo_purnama_flutter/features/payment/data/models/payment_model.dart';
import 'package:warmindo_purnama_flutter/features/payment/domain/repositories/payment_repository_impl.dart';
import 'package:warmindo_purnama_flutter/features/payment/presentation/pages/payment_page.dart';
import 'package:warmindo_purnama_flutter/features/payment/presentation/providers/payment_provider.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/pages/home_page.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/pages/table_status_page.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/pages/payment_list_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/product_manage_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/category_manage_page.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/pages/user_manage_page.dart';

/// Arguments for payment route
/// Can hold just orderId (new payment) or orderId + existingPayment (resuming payment)
class PaymentRouteArgs {
  final int orderId;
  final PaymentModel? existingPayment;

  const PaymentRouteArgs({
    required this.orderId,
    this.existingPayment,
  });
}

/// App router with named routes configuration.
class AppRouter {
  AppRouter._();

  /// Named routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orderList = '/orders';
  static const String orderDetail = '/order-detail';
  static const String tableStatus = '/kasir/tables';
  static const String paymentList = '/kasir/payments';
  static const String productManage = '/admin/products';
  static const String categoryManage = '/admin/categories';
  static const String userManage = '/admin/users';

  /// Route generator function
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginPage(), settings);
      case register:
        return _buildRoute(const RegisterPage(), settings);
      case home:
        return _buildRoute(const HomePage(), settings);
      case cart:
        return _buildRoute(const CartPage(), settings);
      case checkout:
        return _buildRoute(const CheckoutPage(), settings);
      case payment:
        final args = settings.arguments as PaymentRouteArgs;
        // Create scoped PaymentProvider for each payment session
        final dioClient = DioClient(SecureStorage());
        final paymentDataSource = PaymentRemoteDataSource(dioClient);
        final paymentRepository = PaymentRepositoryImpl(dataSource: paymentDataSource);
        return _buildRoute(
          ChangeNotifierProvider(
            create: (_) {
              final provider = PaymentProvider(repository: paymentRepository);
              // If there's an existing payment, set it immediately
              if (args.existingPayment != null) {
                provider.setExistingPayment(args.existingPayment!);
              }
              return provider;
            },
            child: PaymentPage(orderId: args.orderId),
          ),
          settings,
        );
      case orderList:
        return _buildRoute(const OrderListPage(), settings);
      case orderDetail:
        final orderId = settings.arguments as int;
        return _buildRoute(OrderDetailPage(orderId: orderId), settings);
      case tableStatus:
        return _buildRoute(const TableStatusPage(), settings);
      case paymentList:
        return _buildRoute(const PaymentListPage(), settings);
      case productManage:
        return _buildRoute(const ProductManagePage(), settings);
      case categoryManage:
        return _buildRoute(const CategoryManagePage(), settings);
      case userManage:
        return _buildRoute(const UserManagePage(), settings);
      case dashboard:
        return _buildRoute(const _DashboardPage(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

/// Placeholder dashboard page - will be replaced with actual implementation
class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.deepOrange,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Warmindo Purnama',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}