import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
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
      builder: (context) => AlertDialog(
        title: const Text('Hapus kategori?'),
        content: Text(
          '${category.name} akan dihapus. Produk yang menggunakan kategori ini mungkin terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
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
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      final error = provider.errorMessage;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menghapus kategori'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeoAppBar(
        title: 'KELOLA KATEGORI'
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCategories,
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final data = _isLoading && _categories.isEmpty ? _fakeCategories : _categories;

    if (data.isEmpty) {
      return const Center(
        child: Text('Belum ada kategori'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: Colors.deepOrange,
      child: Skeletonizer(
        enabled: _isLoading && _categories.isEmpty,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final category = data[index];
            return ListTile(
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => _openForm(context, category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _confirmDelete(context, category),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}