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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize dependencies (manual DI)
  final secureStorage = SecureStorage();
  final dioClient = DioClient(secureStorage);
  final authRemoteDataSource = AuthRemoteDataSource(dioClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource, secureStorage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository)..checkAuthStatus(),
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

          // Navigate ke dashboard jika authenticated
          if (authProvider.isAuthenticated) {
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