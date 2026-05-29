import 'package:logger/logger.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/create_payment_request_model.dart';
import 'payment_repository.dart';

/// Concrete implementation of PaymentRepository
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({PaymentRemoteDataSource? dataSource})
      : _dataSource = dataSource;

  final PaymentRemoteDataSource? _dataSource;
  final Logger _log = Logger();

  @override
  Future<PaymentModel> createPayment({
    required int orderId,
    required CreatePaymentRequestModel request,
  }) async {
    if (_dataSource == null) {
      throw Exception('PaymentRemoteDataSource not initialized');
    }
    _log.i('[PaymentRepositoryImpl] Creating payment for order $orderId...');
    try {
      final payment = await _dataSource!.createPayment(
        orderId: orderId,
        request: request,
      );
      _log.i('[PaymentRepositoryImpl] Payment created successfully');
      return payment;
    } catch (e, st) {
      _log.e('[PaymentRepositoryImpl] Failed to create payment', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<PaymentModel> getPaymentDetail(int paymentId) async {
    if (_dataSource == null) {
      throw Exception('PaymentRemoteDataSource not initialized');
    }
    // Silent log - don't throw exception as this is called during polling
    try {
      final payment = await _dataSource!.getPaymentDetail(paymentId);
      return payment;
    } catch (e, st) {
      _log.w('[PaymentRepositoryImpl] Failed to get payment detail', error: e, stackTrace: st);
      rethrow;
    }
  }
}