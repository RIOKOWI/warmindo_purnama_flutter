import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../checkout/data/models/order_model.dart';
import '../../data/models/order_list_model.dart';

/// Remote data source for order API calls
class OrderRemoteDataSource {
  OrderRemoteDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// GET /orders?page={page} - Get paginated orders
  Future<OrderListModel> getOrders({int page = 1}) async {
    try {
      _log.d('[OrderRemoteDataSource] Fetching orders page $page...');
      final response = await _dioClient.dio.get(
        ApiConstants.orders,
        queryParameters: {'page': page},
      );
      _log.d('[OrderRemoteDataSource] Orders fetched successfully');
      return OrderListModel.fromJson(response.data);
    } on DioException catch (e, st) {
      _log.e('[OrderRemoteDataSource] Failed to fetch orders', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// GET /orders/{orderId} - Get single order detail
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      _log.d('[OrderRemoteDataSource] Fetching order detail: $orderId');
      final response = await _dioClient.dio.get(
        ApiConstants.orderDetail(orderId),
      );
      _log.d('[OrderRemoteDataSource] Order detail fetched successfully');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e, st) {
      _log.e('[OrderRemoteDataSource] Failed to fetch order detail: $orderId', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// PATCH /orders/{orderId}/cancel - Cancel an order
  Future<OrderModel> cancelOrder(int orderId) async {
    try {
      _log.d('[OrderRemoteDataSource] Cancelling order: $orderId');
      final response = await _dioClient.dio.patch(
        ApiConstants.orderCancel(orderId),
      );
      _log.d('[OrderRemoteDataSource] Order cancelled successfully');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e, st) {
      _log.e('[OrderRemoteDataSource] Failed to cancel order: $orderId', error: e, stackTrace: st);
      rethrow;
    }
  }
}