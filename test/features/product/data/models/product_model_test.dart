import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    final tCategoryJson = {
      'id': 82,
      'name': 'Makanan',
    };

    final tJson = {
      'id': 91,
      'name': 'Nasi Goreng',
      'description': 'Nasi goreng dengan bumbu khas warmindo purnama',
      'price': 1000,
      'stock': 50,
      'image_url': 'https://i.ibb.co.com/tPJbDmkH/nasi-goreng.webp',
      'category': tCategoryJson,
    };

    test('fromJson harus menghasilkan model yang benar', () {
      final result = ProductModel.fromJson(tJson);

      expect(result.id, 91);
      expect(result.name, 'Nasi Goreng');
      expect(result.description, 'Nasi goreng dengan bumbu khas warmindo purnama');
      expect(result.price, 1000);
      expect(result.stock, 50);
      expect(result.imageUrl, 'https://i.ibb.co.com/tPJbDmkH/nasi-goreng.webp');
      expect(result.category.id, 82);
      expect(result.category.name, 'Makanan');
    });

    test('toJson harus mengembalikan map yang benar', () {
      final model = ProductModel.fromJson(tJson);
      final json = model.toJson();

      expect(json['id'], 91);
      expect(json['name'], 'Nasi Goreng');
      expect(json['price'], 1000);
      expect(json['stock'], 50);
      expect(json['image_url'], 'https://i.ibb.co.com/tPJbDmkH/nasi-goreng.webp');
      expect(json['category'], tCategoryJson);
    });

    test('isAvailable harus true saat stock > 0', () {
      final model = ProductModel.fromJson(tJson);
      expect(model.isAvailable, true);
    });

    test('isAvailable harus false saat stock = 0', () {
      final outOfStockJson = {...tJson, 'stock': 0};
      final model = ProductModel.fromJson(outOfStockJson);
      expect(model.isAvailable, false);
    });

    test('imageUrl kosong harus menggunakan empty string', () {
      final noImageJson = {...tJson, 'image_url': null};
      final model = ProductModel.fromJson(noImageJson);
      expect(model.imageUrl, '');
    });

    test('category harus berupa CategoryModel', () {
      final model = ProductModel.fromJson(tJson);
      expect(model.category, isA<CategoryModel>());
    });
  });
}