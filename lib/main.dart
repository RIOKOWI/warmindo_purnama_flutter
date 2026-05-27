import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/services/dio_client.dart';
import 'core/services/secure_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/domain/auth_status.dart';
import 'features/auth/domain/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/domain/repositories/cart_repository_impl.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/domain/repositories/product_repository_impl.dart';
import 'features/product/presentation/pages/home_page.dart';
import 'features/product/presentation/providers/product_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize dependencies (manual DI)
  final secureStorage = SecureStorage();
  final dioClient = DioClient(secureStorage);
  final authRemoteDataSource = AuthRemoteDataSource(dioClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource, secureStorage);

  // Product dependencies
  final productRemoteDataSource = ProductRemoteDataSource(dioClient);
  final productRepository = ProductRepositoryImpl(productRemoteDataSource);

  // Cart dependencies
  final cartRemoteDataSource = CartRemoteDataSource(dioClient);
  final cartRepository = CartRepositoryImpl(cartRemoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository)..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(cartRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warmindo Purnama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Splash/Loading screen saat check auth
          if (authProvider.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: Colors.deepOrange,
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(
                      color: Colors.deepOrange,
                    ),
                  ],
                ),
              ),
            );
          }

          // Navigate berdasarkan role jika authenticated
          if (authProvider.isAuthenticated) {
            // Customer role -> show product menu (HomePage)
            if (authProvider.role == 'customer') {
              return const _CustomerHomePage();
            }
            // Admin/Kasir -> show dashboard
            return const _DashboardPage();
          }

          // Navigate ke login jika unauthenticated
          return const LoginPage();
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// Customer home page with auth guard (customer role only)
class _CustomerHomePage extends StatelessWidget {
  const _CustomerHomePage();

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

/// Dashboard page shown after successful authentication
class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${auth.name ?? 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${auth.role ?? 'Unknown'}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}