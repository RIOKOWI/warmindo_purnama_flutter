import 'package:logger/logger.dart';
import '../../data/models/order_list_model.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../../checkout/data/models/order_model.dart';
import 'order_repository.dart';

/// Concrete implementation of OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required OrderRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final OrderRemoteDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<OrderListModel> getOrders({int page = 1}) async {
    _log.i('[OrderRepositoryImpl] Fetching orders page $page...');
    try {
      final result = await _dataSource.getOrders(page: page);
      _log.i('[OrderRepositoryImpl] Retrieved ${result.orders.length} orders');
      return result;
    } catch (e, st) {
      _log.e('[OrderRepositoryImpl] Failed to fetch orders', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    _log.i('[OrderRepositoryImpl] Fetching order detail: $orderId');
    try {
      final result = await _dataSource.getOrderDetail(orderId);
      _log.i('[OrderRepositoryImpl] Retrieved order: ${result.invoiceNumber}');
      return result;
    } catch (e, st) {
      _log.e('[OrderRepositoryImpl] Failed to fetch order detail: $orderId', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<OrderModel> cancelOrder(int orderId) async {
    _log.i('[OrderRepositoryImpl] Cancelling order: $orderId');
    try {
      final result = await _dataSource.cancelOrder(orderId);
      _log.i('[OrderRepositoryImpl] Order cancelled: ${result.invoiceNumber}');
      return result;
    } catch (e, st) {
      _log.e('[OrderRepositoryImpl] Failed to cancel order: $orderId', error: e, stackTrace: st);
      rethrow;
    }
  }
}