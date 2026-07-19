import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';

/// Abstract repository interface for order analytics
abstract class OrderAnalyticsRepository {
  /// Get order analytics with period filter
  Future<OrderAnalyticsModel> getOrderAnalytics({
    required AnalyticsPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  });
}
