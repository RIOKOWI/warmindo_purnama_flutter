import '../../data/models/order_type_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/create_order_request_model.dart';

/// Abstract repository interface for checkout operations
abstract class CheckoutRepository {
  /// Get list of available order types
  Future<List<OrderTypeModel>> getOrderTypes();

  /// Get list of available tables
  Future<List<TableModel>> getAvailableTables();

  /// Create a new order
  Future<OrderModel> createOrder(CreateOrderRequestModel request);
}
