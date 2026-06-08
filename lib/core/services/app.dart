import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/app_router.dart';
import 'secure_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/customer_shell.dart';
import '../widgets/kasir_shell.dart';
import '../widgets/admin_shell.dart';
import '../../features/auth/domain/auth_status.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/splash/pages/app.dart';
import '../../features/splash/widgets/onboarding_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showOnboarding = false;
  bool _onboardingChecked = false;
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final hasSeen = await _secureStorage.hasSeenOnboarding();
    if (mounted) {
      setState(() {
        _showOnboarding = !hasSeen;
        _onboardingChecked = true;
      });
    }
  }

  void _onOnboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      title: 'Warmindo Purnama',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _buildHome(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  Widget _buildHome() {
    if (!_onboardingChecked) {
      return const SplashPage();
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.status == AuthStatus.initial) {
          return const SplashPage();
        }

        if (auth.isAuthenticated) {
          return switch (auth.role) {
            'customer' => const CustomerShell(),
            'kasir' => const KasirShell(),
            'admin' => const AdminShell(),
            _ => const CustomerShell(),
          };
        }

        return const LoginPage();
      },
    );
  }
}