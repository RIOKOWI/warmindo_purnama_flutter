import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/errors/error_handler.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import '../models/table_model.dart';

/// Remote data source untuk table API calls
class TableRemoteDataSource {
  TableRemoteDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// Ambil semua meja dari API
  Future<List<TableModel>> getAllTables() async {
    try {
      _log.i('[TableRemoteDataSource] Fetching all tables');

      final response = await _dioClient.dio.get(ApiConstants.tables);

      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List;

      _log.d('[TableRemoteDataSource] Fetched ${list.length} tables');

      return list.map((e) => TableModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      _log.e('[TableRemoteDataSource] Failed to fetch tables', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Update status meja di API
  Future<TableModel> updateTableStatus({
    required int tableId,
    required String status,
  }) async {
    try {
      _log.i('[TableRemoteDataSource] Update table $tableId → $status');

      final response = await _dioClient.dio.patch(
        ApiConstants.tableStatus(tableId),
        data: {'status': status},
      );

      final data = response.data as Map<String, dynamic>;
      final tableData = data['data'] as Map<String, dynamic>;

      _log.d('[TableRemoteDataSource] Table $tableId updated to $status');

      return TableModel.fromJson(tableData);
    } catch (e, st) {
      _log.e('[TableRemoteDataSource] Failed to update table $tableId', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }
}