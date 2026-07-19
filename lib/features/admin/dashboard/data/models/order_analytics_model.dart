import 'package:equatable/equatable.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';

/// Model for order analytics response
class OrderAnalyticsModel extends Equatable {
  final List<OrderModel> orders;
  final int totalOrders;
  final int totalRevenue;
  final int pendingCount;
  final int completedCount;
  final int cancelledCount;

  const OrderAnalyticsModel({
    required this.orders,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingCount,
    required this.completedCount,
    required this.cancelledCount,
  });

  factory OrderAnalyticsModel.fromJson(Map<String, dynamic> json) {
    // API returns paginated response: { "data": { "data": [...], "meta": {...} } }
    final wrapper = json['data'] as Map<String, dynamic>;
    final data = wrapper['data'] as List<dynamic>;
    final orders = data
        .map((orderJson) => OrderModel.fromJson(orderJson as Map<String, dynamic>))
        .toList();

    int totalRevenue = 0;
    int pendingCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;

    for (final order in orders) {
      if (order.status == 'completed' || order.status == 'paid') {
        completedCount++;
        totalRevenue += order.totalAmount;
      } else if (order.status == 'pending') {
        pendingCount++;
      } else if (order.status == 'cancelled') {
        cancelledCount++;
      }
    }

    return OrderAnalyticsModel(
      orders: orders,
      totalOrders: orders.length,
      totalRevenue: totalRevenue,
      pendingCount: pendingCount,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        totalOrders,
        totalRevenue,
        pendingCount,
        completedCount,
        cancelledCount,
      ];
}

/// Enum for analytics period filter
enum AnalyticsPeriod {
  day('day', 'Hari Ini'),
  week('week', 'Minggu Ini'),
  month('month', 'Bulan Ini'),
  custom('custom', 'Kustom');

  final String value;
  final String label;

  const AnalyticsPeriod(this.value, this.label);
}
