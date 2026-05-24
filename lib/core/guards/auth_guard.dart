import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/features/auth/domain/auth_status.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';

/// Guard widget for pages that require authentication.
///
/// - If authenticated → show child
/// - If loading → show CircularProgressIndicator
/// - Otherwise → show LoginPage
class AuthGuard extends StatelessWidget {
  const AuthGuard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.authenticated:
            return child;
          case AuthStatus.loading:
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            // For now, navigate to login route
            // In a real app, you might use Navigator.pushReplacementNamed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, AppRouter.login);
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}