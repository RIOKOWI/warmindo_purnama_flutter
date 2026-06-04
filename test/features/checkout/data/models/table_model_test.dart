import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/table_model.dart';

void main() {
  group('TableModel', () {
    final tJson = {
      'id': 1,
      'table_number': 'MEJA 01',
      'status': 'available',
      'created_at': '2026-05-15T01:49:42+00:00',
      'updated_at': '2026-05-15T01:49:42+00:00',
    };

    test('fromJson menghasilkan model yang benar (key table_number)', () {
      final result = TableModel.fromJson(tJson);
      expect(result.id, 1);
      expect(result.tableNumber, 'MEJA 01');
      expect(result.status, 'available');
    });

    test('toJson mengembalikan map yang benar', () {
      final model = TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available');
      final json = model.toJson();
      expect(json['id'], 1);
      expect(json['table_number'], 'MEJA 01');
      expect(json['status'], 'available');
    });

    test('isAvailable true jika status == available', () {
      final model = TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available');
      expect(model.isAvailable, true);
    });

    test('isAvailable false jika status == occupied', () {
      final model = TableModel(id: 2, tableNumber: 'MEJA 02', status: 'occupied');
      expect(model.isAvailable, false);
    });

    test('props equality benar', () {
      final model1 = TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available');
      final model2 = TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available');
      final model3 = TableModel(id: 2, tableNumber: 'MEJA 02', status: 'occupied');
      expect(model1.props, equals(model2.props));
      expect(model1.props, isNot(equals(model3.props)));
    });
  });
}
