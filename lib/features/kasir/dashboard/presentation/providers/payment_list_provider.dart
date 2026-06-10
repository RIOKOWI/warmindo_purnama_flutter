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
  List<PaymentListItemModel> _allPayments = []; // Menyimpan semua data untuk stats
  String? _activeFilter;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isFetchingAll = false; // Flag untuk fetch semua halaman
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;

  // Getters
  List<PaymentListItemModel> get payments => _payments;
  String? get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isFetchingAll => _isFetchingAll;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _currentPage < _lastPage;

  /// Total completed payments (dari semua data)
  int get totalCompleted =>
      _allPayments.where((p) => p.isCompleted).length;

  /// Total pending payments (dari semua data)
  int get totalPending =>
      _allPayments.where((p) => p.isPending).length;

  /// Grand total of all payments (dari semua data)
  int get grandTotal =>
      _allPayments.fold(0, (sum, p) => sum + p.totalPayment);

  /// Ambil semua payment dengan pagination
  Future<void> fetchPayments({bool refresh = false, String? statusFilter}) async {
    if (refresh) {
      _currentPage = 1;
      _payments = [];
      _allPayments = [];
      _activeFilter = statusFilter;
    }

    _isLoading = _payments.isEmpty;
    _isFetchingAll = refresh && !hasNextPage && _payments.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getPayments(
        page: _currentPage,
        statusFilter: _activeFilter,
      );

      _lastPage = result.lastPage;

      if (refresh) {
        _payments = result.payments;
        _allPayments = result.payments;
      } else {
        _payments = [..._payments, ...result.payments];
        _allPayments = [..._allPayments, ...result.payments];
      }

      _log.i('[PaymentListProvider] Fetched ${result.payments.length} payments, page $_currentPage/$_lastPage');

      // Fetch semua halaman jika ini refresh dan masih ada halaman berikutnya
      if (refresh && hasNextPage) {
        await _fetchAllRemainingPages();
      }
    } catch (e, st) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _log.e('[PaymentListProvider] Failed to fetch payments',
          error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      _isFetchingAll = false;
      notifyListeners();
    }
  }

  /// Fetch semua halaman remaining (untuk stats akurat)
  Future<void> _fetchAllRemainingPages() async {
    while (hasNextPage) {
      _currentPage++;
      try {
        final result = await _repository.getPayments(
          page: _currentPage,
          statusFilter: _activeFilter,
        );

        _allPayments = [..._allPayments, ...result.payments];
        _lastPage = result.lastPage;

        _log.d('[PaymentListProvider] Fetched all page: $_currentPage/$_lastPage');
      } catch (e, st) {
        _log.e('[PaymentListProvider] Failed to fetch page $_currentPage', error: e, stackTrace: st);
        break;
      }
    }
    _log.i('[PaymentListProvider] All pages fetched. Total: ${_allPayments.length} payments');
  }

  /// Load more payments (pagination)
  Future<void> loadMore() async {
    // Guard - tidak perlu load more karena kita sudah fetch semua
    if (!hasNextPage || _isLoading || _isLoadingMore || _isFetchingAll) return;

    _currentPage++;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getPayments(
        page: _currentPage,
        statusFilter: _activeFilter,
      );

      _payments = [..._payments, ...result.payments];
      _allPayments = [..._allPayments, ...result.payments];
      _lastPage = result.lastPage;
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