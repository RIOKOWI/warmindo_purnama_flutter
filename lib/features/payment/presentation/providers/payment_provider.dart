import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/create_payment_request_model.dart';
import '../../domain/repositories/payment_repository.dart';

/// Provider for managing payment state and operations
class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentRepository? repository})
      : _repository = repository;

  final PaymentRepository? _repository;
  final Logger _log = Logger();

  PaymentMethod _selectedMethod = PaymentMethod.qris;
  PaymentModel? _payment;
  bool _isCreating = false;
  bool _isPolling = false;
  String? _errorMessage;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  // Getters
  PaymentMethod get selectedMethod => _selectedMethod;
  PaymentModel? get payment => _payment;
  bool get isCreating => _isCreating;
  bool get isPolling => _isPolling;
  String? get errorMessage => _errorMessage;
  Duration get remainingTime => _remainingTime;
  bool get hasPayment => _payment != null;
  bool get isCompleted => _payment?.isCompleted ?? false;
  bool get isExpired => _payment?.isExpired ?? false;

  /// Select a payment method
  void selectMethod(PaymentMethod method) {
    // Don't allow change if payment already exists
    if (hasPayment) return;
    _selectedMethod = method;
    _log.i('[PaymentProvider] Payment method selected: ${method.label}');
    notifyListeners();
  }

  /// Create payment for an order
  Future<bool> createPayment(int orderId) async {
    // Reset stale payment state at the start
    _payment = null;
    _errorMessage = null;

    if (_repository == null) {
      _errorMessage = 'Repository not initialized';
      notifyListeners();
      return false;
    }

    _isCreating = true;
    notifyListeners();

    try {
      _log.i('[PaymentProvider] Creating payment for order $orderId...');
      final request = CreatePaymentRequestModel(
        paymentMethod: _selectedMethod.value,
      );

      _payment = await _repository.createPayment(
        orderId: orderId,
        request: request,
      );

      _log.i('[PaymentProvider] Payment created successfully: ${_payment!.id}');
      _startCountdown();
      _startPolling();

      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      _log.e('[PaymentProvider] Failed to create payment', error: e, stackTrace: st);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  /// Start polling for payment status updates
  void _startPolling() {
    _log.i('[PaymentProvider] Starting polling...');
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPaymentStatus();
    });
  }

  /// Check payment status (called during polling)
  Future<void> _checkPaymentStatus() async {
    if (_payment == null) return;

    _isPolling = true;
    notifyListeners();

    try {
      final updatedPayment = await _repository!.getPaymentDetail(_payment!.id);
      _payment = updatedPayment;
      _log.d('[PaymentProvider] Payment status: ${updatedPayment.status}');

      // Stop timers if payment is completed or expired
      if (updatedPayment.isCompleted || updatedPayment.isExpired) {
        _stopTimers();
      }
    } catch (e, st) {
      // Silent fail - don't show error to user during polling
      _log.w('[PaymentProvider] Failed to check payment status', error: e, stackTrace: st);
    } finally {
      _isPolling = false;
      notifyListeners();
    }
  }

  /// Refresh payment status manually (called when user taps "Cek Status")
  Future<void> refreshStatus() async {
    _log.i('[PaymentProvider] Refreshing payment status...');
    await _checkPaymentStatus();
  }

  /// Start countdown timer
  void _startCountdown() {
    if (_payment == null) return;

    _remainingTime = _payment!.expiredAt.difference(DateTime.now());
    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }

    _log.i('[PaymentProvider] Starting countdown: $_remainingTime');
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingTime -= const Duration(seconds: 1);
      if (_remainingTime.inSeconds <= 0) {
        _remainingTime = Duration.zero;
        _stopTimers();
      }
      notifyListeners();
    });
  }

  /// Stop all timers
  void _stopTimers() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _log.i('[PaymentProvider] Timers stopped');
  }

  /// Cleanup - called from dispose()
  void cleanup() {
    _stopTimers();
    _payment = null;
    _errorMessage = null;
    _remainingTime = Duration.zero;
    _selectedMethod = PaymentMethod.qris;
    notifyListeners();
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }
}