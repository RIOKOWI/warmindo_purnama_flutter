import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/pages/register_page.dart';

/// App router with named routes configuration.
class AppRouter {
  AppRouter._();

  /// Named routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  /// Route generator function
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginPage(), settings);
      case register:
        return _buildRoute(const RegisterPage(), settings);
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