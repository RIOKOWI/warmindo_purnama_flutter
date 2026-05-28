import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../models/payment_details_model.dart';
import '../models/create_payment_request_model.dart';

/// Remote data source for payment API calls
class PaymentRemoteDataSource {
  PaymentRemoteDataSource(DioClient? dioClient)
      : _dioClient = dioClient;

  final DioClient? _dioClient;
  final Logger _log = Logger();

  DioClient get _client {
    if (_dioClient == null) {
      throw Exception('DioClient not initialized. Please provide valid DioClient.');
    }
    return _dioClient!;
  }

  /// POST /orders/{orderId}/payment - Create payment for an order
  Future<PaymentDetailsModel> createPayment({
    required int orderId,
    required CreatePaymentRequestModel request,
  }) async {
    try {
      _log.d('[PaymentRemoteDataSource] Creating payment for order $orderId...');
      final client = _client;
      final response = await client.dio.post(
        ApiConstants.orderPayment(orderId),
        data: request.toJson(),
      );
      final payment = PaymentDetailsModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      _log.d('[PaymentRemoteDataSource] Payment created: ${payment.id}');
      return payment;
    } on DioException catch (e, st) {
      _log.e('[PaymentRemoteDataSource] Failed to create payment', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// GET /payments/{paymentId} - Get payment details
  Future<PaymentDetailsModel> getPaymentDetails(int paymentId) async {
    try {
      _log.d('[PaymentRemoteDataSource] Fetching payment $paymentId...');
      final client = _client;
      final response = await client.dio.get(ApiConstants.paymentDetails(paymentId));
      final payment = PaymentDetailsModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      _log.d('[PaymentRemoteDataSource] Payment details fetched');
      return payment;
    } on DioException catch (e, st) {
      _log.e('[PaymentRemoteDataSource] Failed to fetch payment details', error: e, stackTrace: st);
      rethrow;
    }
  }
}
