import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_text_field.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigasi berdasarkan role user
      _navigateBasedOnRole(auth.role);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateBasedOnRole(String? role) {
    final navigator = AppRouter.navigatorKey.currentState;
    if (navigator == null) return;

    switch (role) {
      case 'admin':
        navigator.pushNamedAndRemoveUntil(AppRouter.adminShell, (route) => false);
        break;
      case 'kasir':
        navigator.pushNamedAndRemoveUntil(AppRouter.kasirShell, (route) => false);
        break;
      case 'customer':
      default:
        navigator.pushNamedAndRemoveUntil(AppRouter.customerShell, (route) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      // Logo
                      NeoCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.restaurant_menu,
                              size: 60,
                              color: AppColors.accent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'WARMINDO',
                              style: AppTextStyles.headline.copyWith(
                                letterSpacing: 3,
                              ),
                            ),
                            Text(
                              'PURNAMA',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.accent,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email field
                      NeoTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!v.contains('@')) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      NeoTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.text,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Login button
                      NeoButton(
                        label: 'MASUK',
                        isLoading: auth.isLoading,
                        onPressed: _onLogin,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 16),

                      // Register link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.register);
                          },
                          child: Text(
                            'Belum punya akun? Daftar',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.accent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lottie animation pinned to bottom
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Lottie.asset(
                'assets/lottie/Cup-Noodles.json',
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}