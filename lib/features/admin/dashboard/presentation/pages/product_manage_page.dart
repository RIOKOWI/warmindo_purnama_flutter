import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/providers/product_provider.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/product_admin_provider.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/widgets/product_form_sheet.dart';

/// Fake data for skeleton loading
final _fakeProducts = List.generate(
  7,
  (i) => ProductModel(
    id: i,
    name: 'Produk ${i + 1}',
    description: 'Deskripsi produk',
    price: 25000,
    stock: 10,
    imageUrl: '',
    category: const CategoryModel(id: 1, name: 'Makanan'),
  ),
);

class ProductManagePage extends StatefulWidget {
  const ProductManagePage({super.key});

  @override
  State<ProductManagePage> createState() => _ProductManagePageState();
}

class _ProductManagePageState extends State<ProductManagePage> {
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final productProvider = context.read<ProductProvider>();
      await productProvider.init();

      if (mounted) {
        setState(() {
          _products = List.from(productProvider.products);
          _categories = List.from(productProvider.categories);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _openForm(BuildContext context, ProductModel? product) async {
    final result = await showModalBottomSheet<ProductModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(product: product, categories: _categories),
    );

    if (result != null && mounted) {
      setState(() {
        if (product == null) {
          _products.add(result);
        } else {
          final index = _products.indexWhere((p) => p.id == result.id);
          if (index != -1) _products[index] = result;
        }
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context, ProductModel product) async {
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
              Text('Hapus produk?', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text('${product.name} akan dihapus secara permanen.',
                  style: AppTextStyles.body, textAlign: TextAlign.center),
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

    if (confirmed == true) await _doDelete(context, product);
  }

  Future<void> _doDelete(BuildContext context, ProductModel product) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<ProductAdminProvider>();
    final ok = await provider.deleteProduct(product.id);

    if (ok && mounted) {
      setState(() => _products.removeWhere((p) => p.id == product.id));
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus'), backgroundColor: AppColors.success),
      );
    } else if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal menghapus produk'), backgroundColor: AppColors.error),
      );
    }
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(
        title: 'KELOLA PRODUK',
      ),
      body: _buildBody(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: AppColors.dark, offset: Offset(5, 5), blurRadius: 0)],
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
    if (_error != null) return Center(
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
          Text(_error!, textAlign: TextAlign.center, style: AppTextStyles.body),
          const SizedBox(height: 16),
          NeoButtonSmall(label: 'Coba Lagi', icon: Icons.refresh, onPressed: _loadData),
        ],
      ),
    );

    final data = _isLoading && _products.isEmpty ? _fakeProducts : _products;

    if (data.isEmpty) return Center(
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
            child: Icon(Icons.fastfood, size: 48, color: AppColors.text.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text('Belum ada produk', style: AppTextStyles.headline),
        ],
      ),
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accent,
      child: Skeletonizer(
        enabled: _isLoading && _products.isEmpty,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProductAdminTile(
              product: data[index],
              onEdit: () => _openForm(context, data[index]),
              onDelete: () => _confirmDelete(context, data[index]),
              formatPrice: _formatPrice,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductAdminTile extends StatelessWidget {
  const _ProductAdminTile({required this.product, required this.onEdit, required this.onDelete, required this.formatPrice});

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(int) formatPrice;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dark, width: 2),
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: AppColors.accent)),
                  )
                : const Icon(Icons.fastfood, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${product.category.name} · Rp ${formatPrice(product.price)}',
                    style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isAvailable
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: product.isAvailable ? AppColors.success : AppColors.error,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    product.isAvailable ? 'Stok: ${product.stock}' : 'Habis',
                    style: AppTextStyles.caption.copyWith(
                      color: product.isAvailable ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEdit,
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
            onTap: onDelete,
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
    );
  }
}