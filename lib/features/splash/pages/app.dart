import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/features/auth/domain/auth_status.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/pages/order_list_page.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/pages/home_page.dart';


class App extends StatelessWidget {
  const App({super.key});

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
              return HomePage();
            }
            // Admin/Kasir -> show dashboard
            else { 
              return OrderListPage();
            }
          }

          // Navigate ke login jika unauthenticated
          return const LoginPage();
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}