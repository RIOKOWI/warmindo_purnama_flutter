import 'package:logger/logger.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/models/payment_details_model.dart';
import '../../data/models/create_payment_request_model.dart';
import 'payment_repository.dart';

/// Concrete implementation of PaymentRepository
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({PaymentRemoteDataSource? dataSource})
      : _dataSource = dataSource;

  final PaymentRemoteDataSource? _dataSource;
  final Logger _log = Logger();

  @override
  Future<PaymentDetailsModel> createPayment({
    required int orderId,
    required CreatePaymentRequestModel request,
  }) async {
    if (_dataSource == null) {
      throw Exception('PaymentRemoteDataSource not initialized');
    }
    _log.i('[PaymentRepositoryImpl] Creating payment for order $orderId...');
    try {
      final payment = await _dataSource.createPayment(
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
  Future<PaymentDetailsModel> getPaymentDetails(int paymentId) async {
    if (_dataSource == null) {
      throw Exception('PaymentRemoteDataSource not initialized');
    }
    _log.i('[PaymentRepositoryImpl] Fetching payment details for $paymentId...');
    try {
      final payment = await _dataSource.getPaymentDetails(paymentId);
      _log.i('[PaymentRepositoryImpl] Payment details fetched');
      return payment;
    } catch (e, st) {
      _log.e('[PaymentRepositoryImpl] Failed to fetch payment details', error: e, stackTrace: st);
      rethrow;
    }
  }
}
