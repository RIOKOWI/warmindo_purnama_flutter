import 'package:equatable/equatable.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';

/// Model for paginated order list response
class OrderListModel extends Equatable {
  final List<OrderModel> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  const OrderListModel({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  /// Check if there is a next page
  bool get hasNextPage => currentPage < lastPage;

  factory OrderListModel.fromJson(Map<String, dynamic> json) {
    // Extract data and meta from nested structure
    final data = json['data'] as Map<String, dynamic>;
    final ordersJson = data['data'] as List<dynamic>;
    final meta = data['meta'] as Map<String, dynamic>;

    final orders = ordersJson
        .map((orderJson) => OrderModel.fromJson(orderJson as Map<String, dynamic>))
        .toList();

    return OrderListModel(
      orders: orders,
      currentPage: meta['current_page'] as int,
      lastPage: meta['last_page'] as int,
      total: meta['total'] as int,
    );
  }

  @override
  List<Object?> get props => [orders, currentPage, lastPage, total];
}