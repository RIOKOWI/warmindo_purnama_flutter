import '../../data/models/table_model.dart';

/// Abstract repository untuk table operations
abstract class TableRepository {
  /// Ambil semua meja
  Future<List<TableModel>> getAllTables();

  /// Update status meja
  Future<TableModel> updateTableStatus({
    required int tableId,
    required String status,
  });
}