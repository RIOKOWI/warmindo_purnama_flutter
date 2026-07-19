import 'package:logger/logger.dart';
import '../../data/datasources/table_admin_datasource.dart';
import '../../data/models/table_request_model.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import 'table_admin_repository.dart';

/// Implementation dari TableAdminRepository
class TableAdminRepositoryImpl implements TableAdminRepository {
  TableAdminRepositoryImpl({required TableAdminDataSource dataSource})
      : _dataSource = dataSource;

  final TableAdminDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<List<TableModel>> getTables() async {
    try {
      return await _dataSource.getTables();
    } catch (e, st) {
      _log.e('[TableAdminRepositoryImpl] Failed to get tables', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<TableModel> createTable(TableRequestModel request) async {
    try {
      return await _dataSource.createTable(request);
    } catch (e, st) {
      _log.e('[TableAdminRepositoryImpl] Failed to create table', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<TableModel> updateTable(int id, TableRequestModel request) async {
    try {
      return await _dataSource.updateTable(id, request);
    } catch (e, st) {
      _log.e('[TableAdminRepositoryImpl] Failed to update table', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteTable(int id) async {
    try {
      await _dataSource.deleteTable(id);
    } catch (e, st) {
      _log.e('[TableAdminRepositoryImpl] Failed to delete table', error: e, stackTrace: st);
      rethrow;
    }
  }
}