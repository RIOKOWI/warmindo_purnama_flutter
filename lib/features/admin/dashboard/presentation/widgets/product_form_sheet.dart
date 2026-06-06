import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_request_model.dart';
import 'package:warmindo_purnama_flutter/core/services/image_service.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import '../providers/product_admin_provider.dart';

/// Form sheet untuk create/edit produk
class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({
    super.key,
    this.product,
    required this.categories,
  });

  final ProductModel? product;
  final List<CategoryModel> categories;

  bool get isEditing => product != null;

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  CategoryModel? _selectedCategory;

  /// Gambar baru yang dipilih pengguna (null = belum pilih baru)
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockCtrl = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );

    // Pre-select category if editing
    if (widget.isEditing) {
      _selectedCategory = widget.categories.firstWhere(
        (c) => c.id == widget.product!.category.id,
        orElse: () => widget.categories.first,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImageService.pickAndCropImage(context);
    if (file != null && mounted) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    // Saat create, gambar wajib dipilih
    if (!widget.isEditing && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih gambar produk'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = context.read<ProductAdminProvider>();
    final request = ProductRequestModel(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: int.parse(_priceCtrl.text.trim()),
      stock: int.parse(_stockCtrl.text.trim()),
      image: _selectedImage,
      categoryId: _selectedCategory!.id,
    );

    ProductModel? result;
    if (widget.isEditing) {
      result = await provider.updateProduct(widget.product!.id, request);
    } else {
      result = await provider.createProduct(request);
    }

    if (result != null && mounted) {
      Navigator.pop(context, result);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Widget preview gambar:
  /// 1. _selectedImage != null → Image.file
  /// 2. product.imageUrl tidak kosong → Image.network
  /// 3. Icon(Icons.image)
  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final existingUrl = widget.product?.imageUrl ?? '';
    if (existingUrl.isNotEmpty) {
      return Image.network(
        existingUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return const Center(
      child: Icon(Icons.image, size: 48, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductAdminProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.isEditing ? 'Edit Produk' : 'Tambah Produk',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // --- Image Preview ---
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 8),

              // Pick / Change image button
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: Text(
                  _selectedImage != null
                      ? 'Ganti Gambar'
                      : (widget.isEditing ? 'Ganti Gambar' : 'Pilih Gambar'),
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description field
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Price field
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Harga tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Stock field
              TextFormField(
                controller: _stockCtrl,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Stok tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}