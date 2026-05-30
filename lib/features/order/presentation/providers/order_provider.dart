import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../../checkout/data/models/order_model.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../payment/data/datasources/payment_remote_datasource.dart';
import '../../../payment/data/models/payment_model.dart';
import '../../../payment/domain/repositories/payment_repository_impl.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/order_repository_impl.dart';

/// Provider for order state management
class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderRepository? repository})
      : _repository = repository ?? OrderRepositoryImpl(
            dataSource: OrderRemoteDataSource(
              throw StateError('DioClient must be provided via main.dart'),
            ),
          );

  final OrderRepository _repository;
  final Logger _log = Logger();

  // State
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoadingList = false;
  bool _isLoadingDetail = false;
  bool _isCancelling = false;
  bool _isLoadingPayment = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = false;

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isCancelling => _isCancelling;
  bool get isLoadingPayment => _isLoadingPayment;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;

  /// Fetch orders from API
  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _orders = [];
    }

    _isLoadingList = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[OrderProvider] Fetching orders page $_currentPage...');
      final result = await _repository.getOrders(page: _currentPage);

      if (refresh) {
        _orders = result.orders;
      } else {
        _orders = [..._orders, ...result.orders];
      }

      _hasNextPage = result.hasNextPage;
      _log.i('[OrderProvider] Fetched ${result.orders.length} orders, hasNextPage: $_hasNextPage');
    } catch (e, st) {
      _log.e('[OrderProvider] Failed to fetch orders', error: e, stackTrace: st);
      _errorMessage = 'Gagal memuat pesanan';
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMore() async {
    if (!_hasNextPage || _isLoadingList) return;

    _currentPage++;
    await fetchOrders();
  }

  /// Fetch single order detail
  Future<void> fetchOrderDetail(int orderId) async {
    _isLoadingDetail = true;
    _selectedOrder = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[OrderProvider] Fetching order detail: $orderId');
      _selectedOrder = await _repository.getOrderDetail(orderId);
      _log.i('[OrderProvider] Order detail fetched: ${_selectedOrder?.invoiceNumber}');
    } catch (e, st) {
      _log.e('[OrderProvider] Failed to fetch order detail: $orderId', error: e, stackTrace: st);
      _errorMessage = 'Gagal memuat detail pesanan';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(int orderId) async {
    _isCancelling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[OrderProvider] Cancelling order: $orderId');
      final cancelled = await _repository.cancelOrder(orderId);

      // Update selectedOrder if it matches
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = cancelled;
      }

      // Update order in the list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = cancelled;
      }

      _log.i('[OrderProvider] Order cancelled successfully: ${cancelled.invoiceNumber}');
      return true;
    } catch (e, st) {
      _log.e('[OrderProvider] Failed to cancel order: $orderId', error: e, stackTrace: st);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  /// Get existing payment detail to validate before navigating to payment page
  /// Returns the PaymentModel if valid, null if invalid
  Future<PaymentModel?> getExistingPayment(int paymentId) async {
    _isLoadingPayment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[OrderProvider] Getting existing payment detail: $paymentId');
      final secureStorage = SecureStorage();
      final paymentRepo = PaymentRepositoryImpl(
        dataSource: PaymentRemoteDataSource(DioClient(secureStorage)),
      );
      final payment = await paymentRepo.getPaymentDetail(paymentId);

      if (payment.isCompleted) {
        _errorMessage = 'Pesanan ini sudah dibayar';
        _log.w('[OrderProvider] Payment already completed: $paymentId');
        return null;
      }

      if (payment.isExpired) {
        _errorMessage = 'Waktu pembayaran sudah habis. Silakan buat pesanan baru.';
        _log.w('[OrderProvider] Payment expired: $paymentId');
        return null;
      }

      // Payment still pending - safe to navigate
      _log.i('[OrderProvider] Payment is pending: $paymentId');
      return payment;
    } catch (e, st) {
      _log.e('[OrderProvider] Gagal ambil payment detail', error: e, stackTrace: st);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoadingPayment = false;
      notifyListeners();
    }
  }

  /// Clear selected order (call from dispose)
  void clearSelectedOrder() {
    _selectedOrder = null;
    _errorMessage = null;
    notifyListeners();
  }

  // For testing purposes only
  @visibleForTesting
  void setSelectedOrder(OrderModel? order) {
    _selectedOrder = order;
  }

  @visibleForTesting
  void setOrders(List<OrderModel> orders) {
    _orders = orders;
  }

  @visibleForTesting
  void setErrorMessage(String? message) {
    _errorMessage = message;
  }
}