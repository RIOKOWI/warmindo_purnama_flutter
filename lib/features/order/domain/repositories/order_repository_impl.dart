import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../checkout/data/models/order_model.dart';
import '../../data/models/order_list_model.dart';
import 'order_repository.dart';

/// Factory to create DioClient instance
DioClient _createDioClient() {
  // This will be overridden with proper instance in main.dart via dependency injection
  // For now, create a new instance with a new SecureStorage
  return DioClient(SecureStorage());
}

/// Concrete implementation of OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({DioClient? dioClient})
      : _dioClient = dioClient ?? _createDioClient();

  final DioClient _dioClient;
  final Logger _log = Logger();

  @override
  Future<OrderListModel> getOrders({int page = 1}) async {
    _log.i('[OrderRepositoryImpl] Fetching orders page $page...');
    try {
      final res = await _dioClient.dio.get(
        ApiConstants.orders,
        queryParameters: {'page': page},
      );
      final result = OrderListModel.fromJson(res.data);
      _log.i('[OrderRepositoryImpl] Retrieved ${result.orders.length} orders');
      return result;
    } on DioException catch (e, st) {
      _log.e('[OrderRepositoryImpl] Failed to fetch orders', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    _log.i('[OrderRepositoryImpl] Fetching order detail: $orderId');
    try {
      final res = await _dioClient.dio.get(
        ApiConstants.orderDetail(orderId),
      );
      final result = OrderModel.fromJson(res.data['data']);
      _log.i('[OrderRepositoryImpl] Retrieved order: ${result.invoiceNumber}');
      return result;
    } on DioException catch (e, st) {
      _log.e('[OrderRepositoryImpl] Failed to fetch order detail: $orderId', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<OrderModel> cancelOrder(int orderId) async {
    _log.i('[OrderRepositoryImpl] Cancelling order: $orderId');
    try {
      final res = await _dioClient.dio.patch(
        ApiConstants.orderCancel(orderId),
      );
      final result = OrderModel.fromJson(res.data['data']);
      _log.i('[OrderRepositoryImpl] Order cancelled: ${result.invoiceNumber}');
      return result;
    } on DioException catch (e, st) {
      _log.e('[OrderRepositoryImpl] Failed to cancel order: $orderId', error: e, stackTrace: st);
      final message = e.response?.data['message'] ?? 'Gagal membatalkan pesanan';
      throw Exception(message);
    }
  }
}