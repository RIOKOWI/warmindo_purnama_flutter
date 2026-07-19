import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/errors/error_handler.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';

/// Remote data source for order analytics
class OrderAnalyticsDataSource {
  OrderAnalyticsDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// GET /orders with period filter
  /// - day: Today's orders
  /// - week: This week's orders
  /// - month: This month's orders
  /// - custom: Custom date range (requires start_date and end_date)
  Future<OrderAnalyticsModel> getOrderAnalytics({
    required AnalyticsPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _log.i('[OrderAnalyticsDataSource] Fetching analytics for period: ${period.value}');

      final queryParams = <String, dynamic>{
        'period': period.value,
      };

      if (period == AnalyticsPeriod.custom) {
        if (startDate != null && endDate != null) {
          queryParams['start_date'] = _formatDate(startDate);
          queryParams['end_date'] = _formatDate(endDate);
        } else {
          _log.w('[OrderAnalyticsDataSource] Custom period requires start_date and end_date');
          throw Exception('Custom period requires start_date and end_date');
        }
      }

      _log.d('[OrderAnalyticsDataSource] Query params: $queryParams');

      final response = await _dioClient.dio.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      _log.i('[OrderAnalyticsDataSource] Analytics fetched successfully');
      return OrderAnalyticsModel.fromJson(response.data);
    } catch (e, st) {
      _log.e('[OrderAnalyticsDataSource] Failed to fetch analytics', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
