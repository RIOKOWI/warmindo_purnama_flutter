import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import '../../domain/repositories/table_admin_repository.dart';
import '../../data/models/table_request_model.dart';

/// Provider untuk admin table management
class TableAdminProvider extends ChangeNotifier {
  TableAdminProvider({required TableAdminRepository repository})
      : _repository = repository;

  final TableAdminRepository _repository;
  final Logger _log = Logger();

  // State
  List<TableModel> _tables = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  String? _errorMessage;

  // Getters
  List<TableModel> get tables => _tables;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  int get totalAvailable => _tables.where((t) => t.isAvailable).length;
  int get totalOccupied => _tables.where((t) => t.isOccupied).length;

  /// Fetch all tables
  Future<void> fetchTables({bool refresh = false}) async {
    if (refresh) {
      _tables = [];
    }

    _isLoading = _tables.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[TableAdminProvider] Fetch tables');
      _tables = await _repository.getTables();
      _log.i('[TableAdminProvider] Tables loaded: ${_tables.length}');
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[TableAdminProvider] Failed to fetch tables', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new table
  Future<TableModel?> createTable(TableRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[TableAdminProvider] Creating table: ${request.tableNumber}');
      final result = await _repository.createTable(request);
      _tables.add(result);
      _log.i('[TableAdminProvider] Table created successfully: ${result.id}');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[TableAdminProvider] Failed to create table', error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update existing table
  Future<TableModel?> updateTable(int id, TableRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[TableAdminProvider] Updating table: $id');
      final result = await _repository.updateTable(id, request);
      final index = _tables.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tables[index] = result;
      }
      _log.i('[TableAdminProvider] Table updated successfully: $id');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[TableAdminProvider] Failed to update table', error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Delete table
  Future<bool> deleteTable(int id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[TableAdminProvider] Deleting table: $id');
      await _repository.deleteTable(id);
      _tables.removeWhere((t) => t.id == id);
      _log.i('[TableAdminProvider] Table deleted successfully: $id');
      return true;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[TableAdminProvider] Failed to delete table', error: e, stackTrace: st);
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}