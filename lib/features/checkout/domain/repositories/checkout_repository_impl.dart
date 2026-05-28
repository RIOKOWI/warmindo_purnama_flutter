import 'package:logger/logger.dart';
import '../../data/datasources/checkout_remote_datasource.dart';
import '../../data/models/order_type_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/create_order_request_model.dart';
import 'checkout_repository.dart';

/// Concrete implementation of CheckoutRepository
class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl({CheckoutRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? CheckoutRemoteDataSource(
            throw StateError('DioClient must be provided'),
          );

  final CheckoutRemoteDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<List<OrderTypeModel>> getOrderTypes() async {
    _log.i('[CheckoutRepositoryImpl] Fetching order types...');
    try {
      final orderTypes = await _dataSource.getOrderTypes();
      _log.i('[CheckoutRepositoryImpl] Retrieved ${orderTypes.length} order types');
      return orderTypes;
    } catch (e, st) {
      _log.e('[CheckoutRepositoryImpl] Failed to fetch order types', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<TableModel>> getAvailableTables() async {
    _log.i('[CheckoutRepositoryImpl] Fetching available tables...');
    try {
      final tables = await _dataSource.getAvailableTables();
      _log.i('[CheckoutRepositoryImpl] Retrieved ${tables.length} available tables');
      return tables;
    } catch (e, st) {
      _log.e('[CheckoutRepositoryImpl] Failed to fetch available tables', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<OrderModel> createOrder(CreateOrderRequestModel request) async {
    _log.i('[CheckoutRepositoryImpl] Creating order...');
    try {
      final order = await _dataSource.createOrder(request);
      _log.i('[CheckoutRepositoryImpl] Order created successfully: ${order.invoiceNumber}');
      return order;
    } catch (e, st) {
      _log.e('[CheckoutRepositoryImpl] Failed to create order', error: e, stackTrace: st);
      rethrow;
    }
  }
}
