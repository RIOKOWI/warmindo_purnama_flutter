import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/errors/error_handler.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import '../models/table_request_model.dart';

/// Remote data source untuk admin table operations
class TableAdminDataSource {
  TableAdminDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// Get all tables
  Future<List<TableModel>> getTables() async {
    try {
      _log.i('[TableAdminDataSource] Fetch all tables');

      final response = await _dioClient.dio.get(ApiConstants.tables);

      _log.d('[TableAdminDataSource] Tables fetched successfully');
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => TableModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, st) {
      _log.e('[TableAdminDataSource] Failed to fetch tables', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Create new table
  Future<TableModel> createTable(TableRequestModel request) async {
    try {
      _log.i('[TableAdminDataSource] Create table: ${request.tableNumber}');

      final response = await _dioClient.dio.post(
        ApiConstants.adminTables,
        data: request.toJson(),
      );

      _log.d('[TableAdminDataSource] Table created successfully');
      return TableModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e, st) {
      _log.e('[TableAdminDataSource] Failed to create table', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Update existing table
  Future<TableModel> updateTable(int id, TableRequestModel request) async {
    try {
      _log.i('[TableAdminDataSource] Update table: $id');

      final response = await _dioClient.dio.put(
        ApiConstants.adminTableDetail(id),
        data: request.toJson(),
      );

      _log.d('[TableAdminDataSource] Table updated successfully');
      return TableModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e, st) {
      _log.e('[TableAdminDataSource] Failed to update table', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Delete table
  Future<void> deleteTable(int id) async {
    try {
      _log.i('[TableAdminDataSource] Delete table: $id');

      await _dioClient.dio.delete(ApiConstants.adminTableDetail(id));

      _log.d('[TableAdminDataSource] Table deleted successfully');
    } catch (e, st) {
      _log.e('[TableAdminDataSource] Failed to delete table', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }
}