import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/models/payment_details_model.dart';
import '../../data/models/create_payment_request_model.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/payment_repository_impl.dart';

/// Provider for managing payment state and operations
class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentRepository? repository})
      : _repository = repository ?? PaymentRepositoryImpl(
            dataSource: PaymentRemoteDataSource(null), // DioClient passed from main.dart
          );

  final PaymentRepository _repository;
  final Logger _log = Logger();

  PaymentDetailsModel? _paymentDetails;
  String? _selectedMethod;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  // Getters
  PaymentDetailsModel? get paymentDetails => _paymentDetails;
  String? get selectedMethod => _selectedMethod;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  /// Load payment details for an order
  Future<void> loadPaymentDetails(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[PaymentProvider] Loading payment details for order $orderId...');
      // Note: We create a mock payment for now since order details come from checkout
      // In a real app, we'd fetch from /orders/{orderId}
      _isLoading = false;
      notifyListeners();
    } catch (e, st) {
      _log.e('[PaymentProvider] Failed to load payment details', error: e, stackTrace: st);
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a payment method
  void selectPaymentMethod(String method) {
    _selectedMethod = method;
    _log.i('[PaymentProvider] Payment method selected: $method');
    notifyListeners();
  }

  /// Process payment for an order
  Future<bool> processPayment(int orderId) async {
    if (_selectedMethod == null) {
      _log.w('[PaymentProvider] Cannot process payment: no method selected');
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[PaymentProvider] Processing payment for order $orderId...');
      final request = CreatePaymentRequestModel(
        paymentMethod: _selectedMethod!,
      );

      _paymentDetails = await _repository.createPayment(
        orderId: orderId,
        request: request,
      );

      _log.i('[PaymentProvider] Payment processed successfully');
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      _log.e('[PaymentProvider] Failed to process payment', error: e, stackTrace: st);
      _errorMessage = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset all state
  void reset() {
    _paymentDetails = null;
    _selectedMethod = null;
    _isLoading = false;
    _isProcessing = false;
    _errorMessage = null;
    _log.i('[PaymentProvider] State reset');
    notifyListeners();
  }
}
