import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import 'package:warmindo_purnama_flutter/features/product/domain/repositories/product_repository.dart';
import 'package:warmindo_purnama_flutter/features/product/presentation/providers/product_provider.dart';

// Mock repository for testing
class MockProductRepository implements ProductRepository {
  @override
  Future<List<CategoryModel>> getCategories() async {
    return [
      const CategoryModel(id: 82, name: 'Makanan'),
      const CategoryModel(id: 83, name: 'Minuman'),
    ];
  }

  @override
  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    return [
      ProductModel(
        id: 91,
        name: 'Nasi Goreng',
        description: 'Deskripsi',
        price: 1000,
        stock: 50,
        imageUrl: 'https://example.com/image.webp',
        category: const CategoryModel(id: 82, name: 'Makanan'),
      ),
      ProductModel(
        id: 102,
        name: 'Air Mineral',
        description: 'Deskripsi',
        price: 1000,
        stock: 30,
        imageUrl: 'https://example.com/air.webp',
        category: const CategoryModel(id: 83, name: 'Minuman'),
      ),
    ];
  }
}

void main() {
  group('ProductProvider', () {
    late ProductProvider provider;
    late MockProductRepository mockRepository;

    setUp(() {
      mockRepository = MockProductRepository();
      provider = ProductProvider(mockRepository);
    });

    test('initial state harus benar', () {
      expect(provider.categories, isEmpty);
      expect(provider.products, isEmpty);
      expect(provider.selectedCategoryId, isNull);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('init harus fetch categories dan products', () async {
      await provider.init();

      expect(provider.categories.length, 2);
      expect(provider.products.length, 2);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('selectCategory(null) harus tampilkan semua produk', () async {
      await provider.init();
      provider.selectCategory(null);

      expect(provider.selectedCategoryId, isNull);
      expect(provider.products.length, 2);
    });

    test('selectCategory(82) harus filter ke kategori Makanan', () async {
      await provider.init();
      provider.selectCategory(82);

      expect(provider.selectedCategoryId, 82);
      expect(provider.products.length, 1);
      expect(provider.products.first.name, 'Nasi Goreng');
    });

    test('selectCategory(83) harus filter ke kategori Minuman', () async {
      await provider.init();
      provider.selectCategory(83);

      expect(provider.selectedCategoryId, 83);
      expect(provider.products.length, 1);
      expect(provider.products.first.name, 'Air Mineral');
    });

    test('products getter harus filter berdasarkan selectedCategoryId', () async {
      await provider.init();

      // Default: semua produk
      expect(provider.products.length, 2);

      // Filter: hanya Makanan
      provider.selectCategory(82);
      expect(provider.products.length, 1);
      expect(provider.products.first.category.id, 82);

      // Filter: hanya Minuman
      provider.selectCategory(83);
      expect(provider.products.length, 1);
      expect(provider.products.first.category.id, 83);

      // Reset: semua produk
      provider.selectCategory(null);
      expect(provider.products.length, 2);
    });
  });
}