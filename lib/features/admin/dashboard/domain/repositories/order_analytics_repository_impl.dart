import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/datasources/order_analytics_datasource.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/domain/repositories/order_analytics_repository.dart';

/// Implementation of OrderAnalyticsRepository
class OrderAnalyticsRepositoryImpl implements OrderAnalyticsRepository {
  OrderAnalyticsRepositoryImpl({required this.dataSource});

  final OrderAnalyticsDataSource dataSource;

  @override
  Future<OrderAnalyticsModel> getOrderAnalytics({
    required AnalyticsPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return dataSource.getOrderAnalytics(
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
