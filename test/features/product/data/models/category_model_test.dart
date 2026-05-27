import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    final tJson = {
      'id': 82,
      'name': 'Makanan',
    };

    test('fromJson harus menghasilkan model yang benar', () {
      final result = CategoryModel.fromJson(tJson);

      expect(result.id, 82);
      expect(result.name, 'Makanan');
    });

    test('toJson harus mengembalikan map yang benar', () {
      final model = CategoryModel.fromJson(tJson);
      expect(model.toJson(), tJson);
    });

    test('props harus berisi id dan name', () {
      final model = CategoryModel.fromJson(tJson);

      expect(model.props, [82, 'Makanan']);
    });
  });
}