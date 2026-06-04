import 'package:logger/logger.dart';
import '../../data/datasources/table_remote_datasource.dart';
import '../../data/models/table_model.dart';
import 'table_repository.dart';

/// Implementation dari TableRepository
class TableRepositoryImpl implements TableRepository {
  TableRepositoryImpl({required TableRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final TableRemoteDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<List<TableModel>> getAllTables() async {
    try {
      return await _dataSource.getAllTables();
    } catch (e, st) {
      _log.e('[TableRepositoryImpl] Failed to get all tables', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<TableModel> updateTableStatus({
    required int tableId,
    required String status,
  }) async {
    try {
      return await _dataSource.updateTableStatus(
        tableId: tableId,
        status: status,
      );
    } catch (e, st) {
      _log.e('[TableRepositoryImpl] Failed to update table $tableId', error: e, stackTrace: st);
      rethrow;
    }
  }
}