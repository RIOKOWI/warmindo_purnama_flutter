import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/providers/product_provider.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import '../providers/category_admin_provider.dart';
import '../widgets/category_form_dialog.dart';

/// Fake data for skeleton loading
final _fakeCategories = List.generate(
  7,
  (i) => CategoryModel(id: i, name: 'Kategori ${i + 1}'),
);

/// Halaman management kategori untuk admin
class CategoryManagePage extends StatefulWidget {
  const CategoryManagePage({super.key});

  @override
  State<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      await productProvider.init();

      if (mounted) {
        setState(() {
          _categories = List.from(productProvider.categories);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openForm(BuildContext context, CategoryModel? category) async {
    final result = await showDialog<CategoryModel>(
      context: context,
      builder: (_) => CategoryFormDialog(category: category),
    );

    if (result == null) return;

    if (mounted) {
      setState(() {
        if (category == null) {
          _categories.add(result);
        } else {
          final index = _categories.indexWhere((c) => c.id == result.id);
          if (index != -1) {
            _categories[index] = result;
          }
        }
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.dark, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error, width: 3),
                ),
                child: const Icon(Icons.warning, color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Hapus kategori?', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                '${category.name} akan dihapus. Produk yang menggunakan kategori ini mungkin terpengaruh.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'Batal',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: 'Hapus',
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _doDelete(context, category);
    }
  }

  Future<void> _doDelete(BuildContext context, CategoryModel category) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<CategoryAdminProvider>();
    final ok = await provider.deleteCategory(category.id);

    if (ok && mounted) {
      setState(() {
        _categories.removeWhere((c) => c.id == category.id);
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final error = provider.errorMessage;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menghapus kategori'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(
        title: 'KELOLA KATEGORI'
      ),
      body: _buildBody(),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: AppColors.dark, offset: Offset(5, 5), blurRadius: 0)],
        ),
        child: FloatingActionButton(
          onPressed: () => _openForm(context, null),
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error, width: 3),
              ),
              child: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            NeoButtonSmall(label: 'Coba Lagi', icon: Icons.refresh, onPressed: _loadCategories),
          ],
        ),
      );
    }

    final data = _isLoading && _categories.isEmpty ? _fakeCategories : _categories;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dark, width: 3),
              ),
              child: Icon(Icons.category, size: 48, color: AppColors.text.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text('Belum ada kategori', style: AppTextStyles.headline),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: AppColors.accent,
      child: Skeletonizer(
        enabled: _isLoading && _categories.isEmpty,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final category = data[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: AppTextStyles.title,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openForm(context, category),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.info, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: AppColors.info, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(context, category),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error, width: 2),
                        ),
                        child: const Icon(Icons.delete, color: AppColors.error, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}