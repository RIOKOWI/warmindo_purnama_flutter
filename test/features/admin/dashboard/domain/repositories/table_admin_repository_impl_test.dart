import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/datasources/table_admin_datasource.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/table_request_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/domain/repositories/table_admin_repository_impl.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';

/// Mock datasource untuk testing
class MockTableAdminDataSource implements TableAdminDataSource {
  List<TableModel> mockTables = [];
  bool shouldFail = false;
  int callCount = 0;

  @override
  Future<List<TableModel>> getTables() async {
    callCount++;
    if (shouldFail) throw Exception('Failed to fetch tables');
    return mockTables;
  }

  @override
  Future<TableModel> createTable(TableRequestModel request) async {
    callCount++;
    if (shouldFail) throw Exception('Failed to create table');
    return TableModel(
      id: 999,
      tableNumber: request.tableNumber,
      status: request.status,
    );
  }

  @override
  Future<TableModel> updateTable(int id, TableRequestModel request) async {
    callCount++;
    if (shouldFail) throw Exception('Failed to update table');
    return TableModel(
      id: id,
      tableNumber: request.tableNumber,
      status: request.status,
    );
  }

  @override
  Future<void> deleteTable(int id) async {
    callCount++;
    if (shouldFail) throw Exception('Failed to delete table');
  }
}

void main() {
  late MockTableAdminDataSource mockDataSource;
  late TableAdminRepositoryImpl repository;

  final tTable = TableModel(
    id: 1,
    tableNumber: 'MEJA 01',
    status: 'available',
  );

  setUp(() {
    mockDataSource = MockTableAdminDataSource();
    repository = TableAdminRepositoryImpl(dataSource: mockDataSource);
  });

  group('getTables', () {
    test('memanggil datasource.getTables()', () async {
      mockDataSource.mockTables = [tTable];

      final result = await repository.getTables();

      expect(mockDataSource.callCount, 1);
      expect(result.length, 1);
      expect(result[0].id, 1);
    });

    test('melempar exception jika datasource gagal', () async {
      mockDataSource.shouldFail = true;

      await expectLater(
        () => repository.getTables(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createTable', () {
    test('memanggil datasource.createTable()', () async {
      final request = TableRequestModel(
        tableNumber: 'MEJA 10',
        status: 'available',
      );

      final result = await repository.createTable(request);

      expect(mockDataSource.callCount, 1);
      expect(result.tableNumber, 'MEJA 10');
    });

    test('melempar exception jika datasource gagal', () async {
      mockDataSource.shouldFail = true;

      final request = TableRequestModel(
        tableNumber: 'MEJA 10',
        status: 'available',
      );

      await expectLater(
        () => repository.createTable(request),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateTable', () {
    test('memanggil datasource.updateTable()', () async {
      final request = TableRequestModel(
        tableNumber: 'MEJA 01',
        status: 'occupied',
      );

      final result = await repository.updateTable(1, request);

      expect(mockDataSource.callCount, 1);
      expect(result.status, 'occupied');
    });

    test('melempar exception jika datasource gagal', () async {
      mockDataSource.shouldFail = true;

      final request = TableRequestModel(
        tableNumber: 'MEJA 01',
        status: 'occupied',
      );

      await expectLater(
        () => repository.updateTable(1, request),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteTable', () {
    test('memanggil datasource.deleteTable()', () async {
      await repository.deleteTable(1);

      expect(mockDataSource.callCount, 1);
    });

    test('melempar exception jika datasource gagal', () async {
      mockDataSource.shouldFail = true;

      await expectLater(
        () => repository.deleteTable(1),
        throwsA(isA<Exception>()),
      );
    });
  });
}