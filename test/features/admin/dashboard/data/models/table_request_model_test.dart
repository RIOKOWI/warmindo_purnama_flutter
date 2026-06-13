import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/table_request_model.dart';

void main() {
  group('TableRequestModel', () {
    test('toJson harus menghasilkan map yang benar', () {
      const model = TableRequestModel(
        tableNumber: 'MEJA 01',
        status: 'available',
      );

      final json = model.toJson();

      expect(json['table_number'], 'MEJA 01');
      expect(json['status'], 'available');
    });

    test('fromJson factory tidak ada - model hanya untuk request', () {
      const model = TableRequestModel(
        tableNumber: 'MEJA 05',
        status: 'occupied',
      );

      expect(model.tableNumber, 'MEJA 05');
      expect(model.status, 'occupied');
    });

    test('toJson dengan status occupied', () {
      const model = TableRequestModel(
        tableNumber: 'MEJA 10',
        status: 'occupied',
      );

      final json = model.toJson();

      expect(json['table_number'], 'MEJA 10');
      expect(json['status'], 'occupied');
    });
  });
}
