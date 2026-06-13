import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import '../../domain/repositories/table_repository.dart';
import '../../data/models/table_model.dart';

/// Provider untuk table status management dengan optimistic update
class TableProvider extends ChangeNotifier {
  TableProvider({required TableRepository repository}) : _repository = repository;

  final TableRepository _repository;
  final Logger _log = Logger();

  // State
  List<TableModel> _tables = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TableModel> get tables => _tables;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Filter meja yang tersedia
  List<TableModel> get availableTables =>
      _tables.where((t) => t.isAvailable).toList();

  /// Filter meja yang terisi
  List<TableModel> get occupiedTables =>
      _tables.where((t) => t.isOccupied).toList();

  /// Ambil semua meja dari server
  Future<void> fetchTables() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tables = await _repository.getAllTables();
      _log.i('[TableProvider] Loaded ${_tables.length} tables');
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[TableProvider] Failed to fetch tables', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update status meja dengan optimistic update
  /// Returns true jika sukses, false jika gagal
  Future<bool> updateTableStatus({
    required int tableId,
    required String newStatus,
  }) async {
    // Cari index meja
    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index == -1) {
      _log.w('[TableProvider] Table $tableId not found');
      return false;
    }

    // Simpan state lama untuk rollback
    final oldTable = _tables[index];

    // Optimistic update - UI berubah dulu
    _tables[index] = oldTable.copyWith(status: newStatus);
    _errorMessage = null;
    notifyListeners();

    try {
      // Update dengan data dari server
      final updated = await _repository.updateTableStatus(
        tableId: tableId,
        status: newStatus,
      );
      _tables[index] = updated;
      _log.i('[TableProvider] Table $tableId updated to $newStatus');
      notifyListeners();
      return true;
    } catch (e, st) {
      // Rollback ke state lama
      _tables[index] = oldTable;
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[TableProvider] Failed to update table $tableId', error: e, stackTrace: st);
      notifyListeners();
      return false;
    }
  }

  /// Toggle status meja (available <-> occupied)
  Future<bool> toggleTableStatus(int tableId) async {
    final table = _tables.firstWhere(
      (t) => t.id == tableId,
      orElse: () => throw AppException('Meja tidak ditemukan'),
    );

    final newStatus = table.isAvailable ? 'occupied' : 'available';
    return updateTableStatus(tableId: tableId, newStatus: newStatus);
  }
}