import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import '../../data/models/table_request_model.dart';

/// Abstract repository untuk admin table operations
abstract class TableAdminRepository {
  /// Get all tables
  Future<List<TableModel>> getTables();

  /// Create new table
  Future<TableModel> createTable(TableRequestModel request);

  /// Update existing table
  Future<TableModel> updateTable(int id, TableRequestModel request);

  /// Delete table
  Future<void> deleteTable(int id);
}