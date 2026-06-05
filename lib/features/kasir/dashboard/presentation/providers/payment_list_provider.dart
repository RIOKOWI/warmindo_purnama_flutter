import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/repositories/payment_list_repository.dart';
import '../../data/models/payment_list_model.dart';

/// Provider untuk payment list management dengan pagination dan filter
class PaymentListProvider extends ChangeNotifier {
  PaymentListProvider({required PaymentListRepository repository})
      : _repository = repository;

  final PaymentListRepository _repository;
  final Logger _log = Logger();

  // State
  List<PaymentListItemModel> _payments = [];
  String? _activeFilter;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = false;

  // Getters
  List<PaymentListItemModel> get payments => _payments;
  String? get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;

  /// Total completed payments
  int get totalCompleted =>
      _payments.where((p) => p.isCompleted).length;

  /// Total pending payments
  int get totalPending =>
      _payments.where((p) => p.isPending).length;

  /// Grand total of all payments
  int get grandTotal =>
      _payments.fold(0, (sum, p) => sum + p.totalPayment);

  /// Ambil semua payment dengan pagination
  Future<void> fetchPayments({bool refresh = false, String? statusFilter}) async {
    if (refresh) {
      _currentPage = 1;
      _payments = [];
      _activeFilter = statusFilter;
    }

    // PENTING: _isLoading = _payments.isEmpty
    _isLoading = _payments.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getPayments(
        page: _currentPage,
        statusFilter: _activeFilter,
      );

      if (refresh) {
        _payments = result.payments;
      } else {
        _payments = [..._payments, ...result.payments];
      }

      _hasNextPage = result.hasNextPage;
      _log.i('[PaymentListProvider] Fetched ${result.payments.length} payments');
    } catch (e, st) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _log.e('[PaymentListProvider] Failed to fetch payments',
          error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more payments (pagination)
  Future<void> loadMore() async {
    // Guard
    if (!_hasNextPage || _isLoading || _isLoadingMore) return;

    _currentPage++;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getPayments(
        page: _currentPage,
        statusFilter: _activeFilter,
      );

      _payments = [..._payments, ...result.payments];
      _hasNextPage = result.hasNextPage;
      _log.i('[PaymentListProvider] Loaded more: ${result.payments.length} payments');
    } catch (e, st) {
      // Rollback page
      _currentPage--;
      _log.e('[PaymentListProvider] Failed to load more', error: e, stackTrace: st);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Apply filter
  Future<void> applyFilter(String? status) async {
    // Guard: skip if filter same
    if (_activeFilter == status) return;

    await fetchPayments(refresh: true, statusFilter: status);
  }
}