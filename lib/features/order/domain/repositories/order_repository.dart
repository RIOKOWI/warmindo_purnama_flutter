import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';
import 'package:warmindo_purnama_flutter/features/order/data/models/order_list_model.dart';

/// Abstract repository interface for order operations
abstract class OrderRepository {
  /// Get paginated list of orders
  Future<OrderListModel> getOrders({int page = 1});

  /// Get single order detail by ID
  Future<OrderModel> getOrderDetail(int orderId);

  /// Cancel an order by ID
  Future<OrderModel> cancelOrder(int orderId);
}