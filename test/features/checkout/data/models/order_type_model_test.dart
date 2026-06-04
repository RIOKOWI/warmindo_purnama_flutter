import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_type_model.dart';

void main() {
  group('OrderTypeModel', () {
    final tJson = {
      'id': 1,
      'name': 'dine_in',
      'created_at': '2026-05-15T01:47:53+00:00',
      'updated_at': '2026-05-15T01:47:53+00:00',
    };

    test('fromJson menghasilkan model yang benar', () {
      final result = OrderTypeModel.fromJson(tJson);
      expect(result.id, 1);
      expect(result.name, 'dine_in');
    });

    test('toJson mengembalikan map yang benar', () {
      final model = OrderTypeModel(id: 1, name: 'dine_in');
      final json = model.toJson();
      expect(json['id'], 1);
      expect(json['name'], 'dine_in');
    });

    test('isDineIn true jika name == dine_in', () {
      final model = OrderTypeModel(id: 1, name: 'dine_in');
      expect(model.isDineIn, true);
    });

    test('isDineIn false jika name == take_away', () {
      final model = OrderTypeModel(id: 2, name: 'take_away');
      expect(model.isDineIn, false);
    });

    test('props equality benar', () {
      final model1 = OrderTypeModel(id: 1, name: 'dine_in');
      final model2 = OrderTypeModel(id: 1, name: 'dine_in');
      final model3 = OrderTypeModel(id: 2, name: 'take_away');
      expect(model1.props, equals(model2.props));
      expect(model1.props, isNot(equals(model3.props)));
    });
  });
}
