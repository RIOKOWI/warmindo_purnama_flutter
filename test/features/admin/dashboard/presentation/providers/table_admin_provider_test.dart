import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/table_request_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/domain/repositories/table_admin_repository.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/table_admin_provider.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';

/// Mock repository untuk testing
class MockTableAdminRepository implements TableAdminRepository {
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
  late MockTableAdminRepository mockRepository;
  late TableAdminProvider provider;

  final tTableAvailable = TableModel(
    id: 1,
    tableNumber: 'MEJA 01',
    status: 'available',
  );

  final tTableOccupied = TableModel(
    id: 2,
    tableNumber: 'MEJA 02',
    status: 'occupied',
  );

  final tTableAvailable2 = TableModel(
    id: 3,
    tableNumber: 'MEJA 03',
    status: 'available',
  );

  setUp(() {
    mockRepository = MockTableAdminRepository();
    provider = TableAdminProvider(repository: mockRepository);
  });

  group('fetchTables', () {
    test('isLoading true saat fetch', () async {
      mockRepository.mockTables = [tTableAvailable];

      final future = provider.fetchTables();
      expect(provider.isLoading, true);

      await future;
      expect(provider.isLoading, false);
    });

    test('tables terisi setelah sukses', () async {
      mockRepository.mockTables = [tTableAvailable, tTableOccupied];

      await provider.fetchTables();

      expect(provider.tables.length, 2);
      expect(provider.tables[0].id, 1);
      expect(provider.tables[1].id, 2);
    });

    test('refresh: tables direset', () async {
      mockRepository.mockTables = [tTableAvailable];

      await provider.fetchTables();
      expect(provider.tables.length, 1);

      mockRepository.mockTables = [tTableAvailable, tTableOccupied, tTableAvailable2];
      await provider.fetchTables(refresh: true);

      expect(provider.tables.length, 3);
    });

    test('errorMessage jika gagal', () async {
      mockRepository.shouldFail = true;

      await provider.fetchTables();

      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('Failed to fetch tables'));
    });
  });

  group('createTable', () {
    test('isSubmitting true saat proses', () async {
      final request = TableRequestModel(
        tableNumber: 'MEJA 10',
        status: 'available',
      );

      final future = provider.createTable(request);
      expect(provider.isSubmitting, true);

      await future;
      expect(provider.isSubmitting, false);
    });

    test('table di-add ke list setelah sukses', () async {
      await provider.fetchTables();
      expect(provider.tables.length, 0);

      final request = TableRequestModel(
        tableNumber: 'MEJA 10',
        status: 'available',
      );

      await provider.createTable(request);

      expect(provider.tables.length, 1);
      expect(provider.tables[0].tableNumber, 'MEJA 10');
    });

    test('return null jika gagal', () async {
      mockRepository.shouldFail = true;

      final request = TableRequestModel(
        tableNumber: 'MEJA 10',
        status: 'available',
      );

      final result = await provider.createTable(request);

      expect(result, isNull);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('updateTable', () {
    test('table di-update di list setelah sukses', () async {
      mockRepository.mockTables = [tTableAvailable];
      await provider.fetchTables();

      expect(provider.tables[0].status, 'available');

      final request = TableRequestModel(
        tableNumber: 'MEJA 01',
        status: 'occupied',
      );

      await provider.updateTable(1, request);

      expect(provider.tables[0].status, 'occupied');
    });

    test('return null jika gagal', () async {
      mockRepository.shouldFail = true;

      final request = TableRequestModel(
        tableNumber: 'MEJA 01',
        status: 'occupied',
      );

      final result = await provider.updateTable(1, request);

      expect(result, isNull);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('deleteTable', () {
    test('table dihapus dari list setelah sukses', () async {
      mockRepository.mockTables = [tTableAvailable, tTableOccupied];
      await provider.fetchTables();

      expect(provider.tables.length, 2);

      final success = await provider.deleteTable(1);

      expect(success, true);
      expect(provider.tables.length, 1);
      expect(provider.tables[0].id, 2);
    });

    test('return false jika gagal', () async {
      mockRepository.shouldFail = true;

      final success = await provider.deleteTable(1);

      expect(success, false);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('summary getters', () {
    test('totalAvailable hanya hitung status available', () async {
      mockRepository.mockTables = [tTableAvailable, tTableOccupied, tTableAvailable2];

      await provider.fetchTables();

      expect(provider.totalAvailable, 2);
      expect(provider.totalOccupied, 1);
    });

    test('tables.length adalah total meja', () async {
      mockRepository.mockTables = [tTableAvailable, tTableOccupied, tTableAvailable2];

      await provider.fetchTables();

      expect(provider.tables.length, 3);
    });
  });
}