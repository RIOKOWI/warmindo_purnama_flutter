import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/providers/table_provider.dart';

// Generate with: dart run build_runner build --delete-conflicting-outputs
import '../../../../../mocks.mocks.dart';

void main() {
  late TableProvider provider;
  late MockTableRepository mockRepository;

  setUp(() {
    mockRepository = MockTableRepository();
    provider = TableProvider(repository: mockRepository);
  });

  // Test data
  final tAvailableTable = const TableModel(
    id: 1,
    tableNumber: 'MEJA 01',
    status: 'available',
  );

  final tOccupiedTable = const TableModel(
    id: 2,
    tableNumber: 'MEJA 02',
    status: 'occupied',
  );

  group('TableProvider', () {
    group('Getters - Initial State', () {
      test('tables harus return empty list di awal', () {
        expect(provider.tables, isEmpty);
      });

      test('isLoading harus false di awal', () {
        expect(provider.isLoading, false);
      });

      test('errorMessage harus null di awal', () {
        expect(provider.errorMessage, null);
      });

      test('availableTables harus empty di awal', () {
        expect(provider.availableTables, isEmpty);
      });

      test('occupiedTables harus empty di awal', () {
        expect(provider.occupiedTables, isEmpty);
      });
    });

    group('fetchTables', () {
      test('isLoading true saat proses, false setelah selesai', () async {
        // arrange
        when(mockRepository.getAllTables()).thenAnswer(
          (_) async => [tAvailableTable, tOccupiedTable],
        );

        // act
        final future = provider.fetchTables();
        // isLoading should be true during async operation
        expect(provider.isLoading, true);
        await future;

        // assert
        expect(provider.isLoading, false);
        verify(mockRepository.getAllTables()).called(1);
      });

      test('_tables terisi setelah sukses', () async {
        // arrange
        when(mockRepository.getAllTables()).thenAnswer(
          (_) async => [tAvailableTable, tOccupiedTable],
        );

        // act
        await provider.fetchTables();

        // assert
        expect(provider.tables.length, 2);
        expect(provider.tables[0].id, 1);
        expect(provider.tables[1].id, 2);
      });

      test('errorMessage terisi jika gagal', () async {
        // arrange
        when(mockRepository.getAllTables()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Network error',
          ),
        );

        // act
        await provider.fetchTables();

        // assert
        expect(provider.errorMessage, isNotNull);
        expect(provider.tables, isEmpty);
      });

      test('isLoading false meski gagal (finally)', () async {
        // arrange
        when(mockRepository.getAllTables()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Network error',
          ),
        );

        // act
        await provider.fetchTables();

        // assert
        expect(provider.isLoading, false);
      });

      test('availableTables hanya berisi table dengan status available', () async {
        // arrange
        when(mockRepository.getAllTables()).thenAnswer(
          (_) async => [tAvailableTable, tOccupiedTable],
        );

        // act
        await provider.fetchTables();

        // assert
        expect(provider.availableTables.length, 1);
        expect(provider.availableTables[0].status, 'available');
      });

      test('occupiedTables hanya berisi table dengan status occupied', () async {
        // arrange
        when(mockRepository.getAllTables()).thenAnswer(
          (_) async => [tAvailableTable, tOccupiedTable],
        );

        // act
        await provider.fetchTables();

        // assert
        expect(provider.occupiedTables.length, 1);
        expect(provider.occupiedTables[0].status, 'occupied');
      });
    });

    group('updateTableStatus - Optimistic Update', () {
      setUp(() {
        // Set initial tables
        provider.tables.add(tAvailableTable);
      });

      test('_tables[index] berubah SEBELUM request selesai (optimistic)', () async {
        // arrange
        final updatedTable = tAvailableTable.copyWith(status: 'occupied');
        when(mockRepository.updateTableStatus(
          tableId: 1,
          status: 'occupied',
        )).thenAnswer(
          (_) async {
            // Simulate slow network
            await Future.delayed(const Duration(milliseconds: 50));
            return updatedTable;
          },
        );

        // act
        final future = provider.updateTableStatus(
          tableId: 1,
          newStatus: 'occupied',
        );

        // Assert: optimistic update - status changed immediately
        await Future.delayed(const Duration(milliseconds: 10));
        expect(provider.tables[0].status, 'occupied');

        await future;

        // Final state: should still be occupied with server data
        expect(provider.tables[0].status, 'occupied');
      });

      test('return true dan _tables[index] = data server jika sukses', () async {
        // arrange
        final updatedTable = tAvailableTable.copyWith(status: 'occupied');
        when(mockRepository.updateTableStatus(
          tableId: 1,
          status: 'occupied',
        )).thenAnswer((_) async => updatedTable);

        // act
        final result = await provider.updateTableStatus(
          tableId: 1,
          newStatus: 'occupied',
        );

        // assert
        expect(result, true);
        expect(provider.tables[0].status, 'occupied');
        expect(provider.errorMessage, null);
      });

      test('return false dan _tables[index] = oldTable jika gagal (rollback)', () async {
        // arrange
        when(mockRepository.updateTableStatus(
          tableId: 1,
          status: 'occupied',
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Network error',
          ),
        );

        // act
        final result = await provider.updateTableStatus(
          tableId: 1,
          newStatus: 'occupied',
        );

        // assert
        expect(result, false);
        expect(provider.tables[0].status, 'available'); // Rollback!
        expect(provider.errorMessage, isNotNull);
      });

      test('errorMessage terisi jika gagal', () async {
        // arrange
        when(mockRepository.updateTableStatus(
          tableId: 1,
          status: 'occupied',
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Server error',
          ),
        );

        // act
        await provider.updateTableStatus(
          tableId: 1,
          newStatus: 'occupied',
        );

        // assert
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('Server error'));
      });

      test('return false jika table tidak ditemukan', () async {
        // arrange - no setup needed, table list is empty by default

        // act
        final result = await provider.updateTableStatus(
          tableId: 999,
          newStatus: 'occupied',
        );

        // assert
        expect(result, false);
      });
    });

    group('toggleTableStatus', () {
      test('memanggil updateTableStatus dengan occupied jika isAvailable', () async {
        // arrange
        provider.tables.add(tAvailableTable);
        final updatedTable = tAvailableTable.copyWith(status: 'occupied');
        when(mockRepository.updateTableStatus(
          tableId: 1,
          status: 'occupied',
        )).thenAnswer((_) async => updatedTable);

        // act
        final result = await provider.toggleTableStatus(1);

        // assert
        expect(result, true);
        verify(mockRepository.updateTableStatus(
          tableId: 1,
          status: 'occupied',
        )).called(1);
      });

      test('memanggil updateTableStatus dengan available jika isOccupied', () async {
        // arrange
        provider.tables.add(tOccupiedTable);
        final updatedTable = tOccupiedTable.copyWith(status: 'available');
        when(mockRepository.updateTableStatus(
          tableId: 2,
          status: 'available',
        )).thenAnswer((_) async => updatedTable);

        // act
        final result = await provider.toggleTableStatus(2);

        // assert
        expect(result, true);
        verify(mockRepository.updateTableStatus(
          tableId: 2,
          status: 'available',
        )).called(1);
      });

      test('throw Exception jika meja tidak ditemukan', () async {
        // arrange - empty tables

        // act & assert
        expect(
          () => provider.toggleTableStatus(999),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}