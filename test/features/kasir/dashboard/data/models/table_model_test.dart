import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';

void main() {
  group('TableModel', () {
    final tJson = {
      'id': 1,
      'table_number': 'MEJA 01',
      'status': 'available',
      'created_at': '2026-05-15T01:49:42+00:00',
      'updated_at': '2026-05-15T01:49:42+00:00',
    };

    test('fromJson harus menghasilkan model yang benar', () {
      final result = TableModel.fromJson(tJson);

      expect(result.id, 1);
      expect(result.tableNumber, 'MEJA 01');
      expect(result.status, 'available');
    });

    test('toJson harus mengembalikan map yang benar', () {
      final model = TableModel.fromJson(tJson);
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['table_number'], 'MEJA 01');
      expect(json['status'], 'available');
    });

    test('isAvailable true jika status == available', () {
      final model = TableModel.fromJson(tJson);

      expect(model.isAvailable, true);
      expect(model.isOccupied, false);
    });

    test('isOccupied true jika status == occupied', () {
      final occupiedJson = {...tJson, 'status': 'occupied'};
      final model = TableModel.fromJson(occupiedJson);

      expect(model.isAvailable, false);
      expect(model.isOccupied, true);
    });

    test('copyWith menghasilkan instance baru dengan status berbeda', () {
      final model = TableModel.fromJson(tJson);
      final updated = model.copyWith(status: 'occupied');

      // Instance baru
      expect(identical(model, updated), false);
      // Status berubah
      expect(updated.status, 'occupied');
      // Field lain tetap sama
      expect(updated.id, model.id);
      expect(updated.tableNumber, model.tableNumber);
    });

    test('copyWith tidak mengubah field lain', () {
      final model = TableModel.fromJson(tJson);
      final updated = model.copyWith(status: 'occupied');

      expect(updated.id, 1);
      expect(updated.tableNumber, 'MEJA 01');
    });

    test('props equality benar', () {
      final model1 = TableModel.fromJson(tJson);
      final model2 = TableModel.fromJson(tJson);

      expect(model1, model2);
    });

    test('props berbeda jika content berbeda', () {
      final model1 = TableModel.fromJson(tJson);
      final occupiedJson = {...tJson, 'status': 'occupied'};
      final model2 = TableModel.fromJson(occupiedJson);

      expect(model1, isNot(model2));
    });
  });
}