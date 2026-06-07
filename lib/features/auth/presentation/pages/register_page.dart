import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/routes/app_router.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_text_field.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (!v.contains(RegExp(r'[A-Z]'))) {
      return 'Harus ada huruf kapital';
    }
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Harus ada angka';
    }
    if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Harus ada simbol';
    }
    return null;
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const NeoAppBar(
        title: 'Daftar Akun',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Name field
                NeoTextField(
                  controller: _nameController,
                  label: 'Nama',
                  hint: 'John Doe',
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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

                // Phone field
                NeoTextField(
                  controller: _phoneController,
                  label: 'Nomor HP',
                  hint: '081234567890',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Nomor HP tidak boleh kosong';
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
                  validator: _validatePassword,
                ),
                const SizedBox(height: 8),
                Text(
                  'Password harus mengandung huruf kapital, angka, dan simbol',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 24),

                // Register button
                NeoButton(
                  label: 'DAFTAR',
                  isLoading: auth.isLoading,
                  onPressed: _onRegister,
                  width: double.infinity,
                ),
                const SizedBox(height: 16),

                // Login link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Sudah punya akun? Login',
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
    );
  }
}