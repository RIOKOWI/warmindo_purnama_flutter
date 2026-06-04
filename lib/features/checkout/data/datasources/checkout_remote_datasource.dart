import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../models/order_type_model.dart';
import '../models/table_model.dart';
import '../models/order_model.dart';
import '../models/create_order_request_model.dart';

/// Remote data source for checkout API calls
class CheckoutRemoteDataSource {
  CheckoutRemoteDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// GET /order-types - Get all order types
  Future<List<OrderTypeModel>> getOrderTypes() async {
    try {
      _log.d('[CheckoutRemoteDataSource] Fetching order types...');
      final response = await _dioClient.dio.get(ApiConstants.orderTypes);
      final data = response.data['data'] as List<dynamic>;
      final orderTypes = data
          .map((json) => OrderTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _log.d('[CheckoutRemoteDataSource] Retrieved ${orderTypes.length} order types');
      return orderTypes;
    } on DioException catch (e, st) {
      _log.e('[CheckoutRemoteDataSource] Failed to fetch order types', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// GET /tables/available - Get available tables
  Future<List<TableModel>> getAvailableTables() async {
    try {
      _log.d('[CheckoutRemoteDataSource] Fetching available tables...');
      final response = await _dioClient.dio.get(ApiConstants.tablesAvailable);
      final data = response.data['data'] as List<dynamic>;
      final tables = data
          .map((json) => TableModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _log.d('[CheckoutRemoteDataSource] Retrieved ${tables.length} available tables');
      return tables;
    } on DioException catch (e, st) {
      _log.e('[CheckoutRemoteDataSource] Failed to fetch available tables', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// POST /orders - Create a new order
  Future<OrderModel> createOrder(CreateOrderRequestModel request) async {
    try {
      _log.d('[CheckoutRemoteDataSource] Creating order with request: ${request.toJson()}');
      final response = await _dioClient.dio.post(
        ApiConstants.orders,
        data: request.toJson(),
      );
      final order = OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      _log.d('[CheckoutRemoteDataSource] Order created: ${order.invoiceNumber}');
      return order;
    } on DioException catch (e, st) {
      _log.e('[CheckoutRemoteDataSource] Failed to create order', error: e, stackTrace: st);
      rethrow;
    }
  }
}