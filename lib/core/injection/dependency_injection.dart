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
import '../../features/kasir/dashboard/data/datasources/table_remote_datasource.dart';
import '../../features/kasir/dashboard/domain/repositories/table_repository_impl.dart';
import '../../features/kasir/dashboard/presentation/providers/table_provider.dart';
import '../../features/kasir/dashboard/data/datasources/payment_list_datasource.dart';
import '../../features/kasir/dashboard/domain/repositories/payment_list_repository_impl.dart';
import '../../features/kasir/dashboard/presentation/providers/payment_list_provider.dart';
import '../../features/admin/dashboard/data/datasources/product_admin_datasource.dart';
import '../../features/admin/dashboard/data/datasources/category_admin_datasource.dart';
import '../../features/admin/dashboard/data/datasources/user_admin_datasource.dart';
import '../../features/admin/dashboard/domain/repositories/product_admin_repository_impl.dart';
import '../../features/admin/dashboard/domain/repositories/category_admin_repository_impl.dart';
import '../../features/admin/dashboard/domain/repositories/user_admin_repository_impl.dart';
import '../../features/admin/dashboard/presentation/providers/product_admin_provider.dart';
import '../../features/admin/dashboard/presentation/providers/category_admin_provider.dart';
import '../../features/admin/dashboard/presentation/providers/user_admin_provider.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/domain/repositories/product_repository_impl.dart';
import '../../features/product/presentation/providers/product_provider.dart';
import '../services/dio_client.dart';
import '../services/secure_storage.dart';

/// Core services (singleton instances)
final SecureStorage _secureStorage = SecureStorage();
final DioClient _dioClient = DioClient(_secureStorage);

/// Remote datasources
final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(_dioClient);
final ProductRemoteDataSource _productRemoteDataSource = ProductRemoteDataSource(_dioClient);
final CartRemoteDataSource _cartRemoteDataSource = CartRemoteDataSource(_dioClient);
final CheckoutRemoteDataSource _checkoutRemoteDataSource = CheckoutRemoteDataSource(_dioClient);
final OrderRemoteDataSource _orderRemoteDataSource = OrderRemoteDataSource(_dioClient);
final TableRemoteDataSource _tableRemoteDataSource = TableRemoteDataSource(_dioClient);
final PaymentListDataSource _paymentListDataSource = PaymentListDataSource(_dioClient);

// Admin datasources
final ProductAdminDataSource _productAdminDataSource = ProductAdminDataSource(_dioClient);
final CategoryAdminDataSource _categoryAdminDataSource = CategoryAdminDataSource(_dioClient);
final UserAdminDataSource _userAdminDataSource = UserAdminDataSource(_dioClient);

/// Repositories
final AuthRepositoryImpl _authRepository = AuthRepositoryImpl(_authRemoteDataSource, _secureStorage);
final ProductRepositoryImpl _productRepository = ProductRepositoryImpl(_productRemoteDataSource);
final CartRepositoryImpl _cartRepository = CartRepositoryImpl(_cartRemoteDataSource);
final CheckoutRepositoryImpl _checkoutRepository = CheckoutRepositoryImpl(dataSource: _checkoutRemoteDataSource);
final OrderRepositoryImpl _orderRepository = OrderRepositoryImpl(dataSource: _orderRemoteDataSource);
final TableRepositoryImpl _tableRepository = TableRepositoryImpl(dataSource: _tableRemoteDataSource);
final PaymentListRepositoryImpl _paymentListRepository = PaymentListRepositoryImpl(dataSource: _paymentListDataSource);

// Admin repositories
final ProductAdminRepositoryImpl _productAdminRepository = ProductAdminRepositoryImpl(dataSource: _productAdminDataSource);
final CategoryAdminRepositoryImpl _categoryAdminRepository = CategoryAdminRepositoryImpl(dataSource: _categoryAdminDataSource);
final UserAdminRepositoryImpl _userAdminRepository = UserAdminRepositoryImpl(dataSource: _userAdminDataSource);

class DependencyInjection {
  /// Providers with proper type parameters - type erasure fixed
  static List<ChangeNotifierProvider> get providers => [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(_authRepository, _dioClient)..checkAuthStatus(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(_productRepository),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(_cartRepository),
        ),
        ChangeNotifierProvider<CheckoutProvider>(
          create: (_) => CheckoutProvider(repository: _checkoutRepository),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(repository: _orderRepository),
        ),
        ChangeNotifierProvider<TableProvider>(
          create: (_) => TableProvider(repository: _tableRepository),
        ),
        ChangeNotifierProvider<PaymentListProvider>(
          create: (_) => PaymentListProvider(repository: _paymentListRepository),
        ),
        ChangeNotifierProvider<ProductAdminProvider>(
          create: (_) => ProductAdminProvider(repository: _productAdminRepository),
        ),
        ChangeNotifierProvider<CategoryAdminProvider>(
          create: (_) => CategoryAdminProvider(repository: _categoryAdminRepository),
        ),
        ChangeNotifierProvider<UserAdminProvider>(
          create: (_) => UserAdminProvider(repository: _userAdminRepository),
        ),
      ];
}