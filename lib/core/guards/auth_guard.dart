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
///
/// For role-specific protection, use [RoleGuard] instead.
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

/// Guard widget for pages that require specific role(s).
///
/// - If authenticated AND has correct role → show child
/// - If authenticated but wrong role → redirect based on role
/// - If loading → show CircularProgressIndicator
/// - Otherwise → show LoginPage
class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.child,
    this.allowedRoles = const ['customer', 'kasir', 'admin'],
    this.onUnauthorized,
  });

  /// List of roles allowed to access this page
  final List<String> allowedRoles;

  /// Custom callback when unauthorized (optional)
  final VoidCallback? onUnauthorized;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.authenticated:
            // Check if user has allowed role
            if (allowedRoles.contains(auth.role)) {
              return child;
            }
            // Unauthorized - role not allowed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onUnauthorized?.call();
              // Default redirect based on role
              if (auth.role == 'customer') {
                Navigator.pushReplacementNamed(context, AppRouter.home);
              } else {
                Navigator.pushReplacementNamed(context, AppRouter.dashboard);
              }
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthStatus.loading:
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
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