import 'package:provider/provider.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/domain/repositories/cart_repository_impl.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/checkout/data/datasources/checkout_remote_datasource.dart';
import '../../features/checkout/domain/repositories/checkout_repository_impl.dart';
import '../../features/checkout/presentation/providers/checkout_provider.dart';
import '../../features/order/data/datasources/order_remote_datasource.dart';
import '../../features/order/domain/repositories/order_repository_impl.dart';
import '../../features/order/presentation/providers/order_provider.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/domain/repositories/product_repository_impl.dart';
import '../../features/product/presentation/providers/product_provider.dart';
import '../services/dio_client.dart';
import '../services/secure_storage.dart';

class DependencyInjection {
  static List<ChangeNotifierProvider> get providers {
    // Core services
    final secureStorage = SecureStorage();
    final dioClient = DioClient(secureStorage);

    // Auth
    final authRemoteDataSource = AuthRemoteDataSource(dioClient);
    final authRepository = AuthRepositoryImpl(authRemoteDataSource, secureStorage);

    // Product
    final productRemoteDataSource = ProductRemoteDataSource(dioClient);
    final productRepository = ProductRepositoryImpl(productRemoteDataSource);

    // Cart
    final cartRemoteDataSource = CartRemoteDataSource(dioClient);
    final cartRepository = CartRepositoryImpl(cartRemoteDataSource);

    // Checkout
    final checkoutRemoteDataSource = CheckoutRemoteDataSource(dioClient);
    final checkoutRepository = CheckoutRepositoryImpl(dataSource: checkoutRemoteDataSource);

    // Order
    final orderRemoteDataSource = OrderRemoteDataSource(dioClient);
    final orderRepository = OrderRepositoryImpl(dataSource: orderRemoteDataSource);

    // Return providers — urutan sama dengan main.dart sekarang
    return [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authRepository)..checkAuthStatus(),
      ),
      ChangeNotifierProvider(create: (_) => ProductProvider(productRepository)),
      ChangeNotifierProvider(create: (_) => CartProvider(cartRepository)),
      ChangeNotifierProvider(create: (_) => CheckoutProvider(repository: checkoutRepository)),
      ChangeNotifierProvider(create: (_) => OrderProvider(repository: orderRepository)),
    ];
  }
}