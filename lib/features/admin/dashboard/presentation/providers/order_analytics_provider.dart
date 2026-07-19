import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/domain/repositories/order_analytics_repository.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';

/// Provider for order analytics dashboard
class OrderAnalyticsProvider extends ChangeNotifier {
  OrderAnalyticsProvider({required this.repository});

  final OrderAnalyticsRepository repository;
  final Logger _log = Logger();

  OrderAnalyticsModel? _analytics;
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.day;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _error;

  // Getters
  OrderAnalyticsModel? get analytics => _analytics;
  AnalyticsPeriod get selectedPeriod => _selectedPeriod;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get chart data for bar chart (grouped by date)
  List<ChartData> get chartData {
    if (_analytics == null) return [];

    final Map<String, int> dailyRevenue = {};
    final Map<String, int> dailyCount = {};

    for (final order in _analytics!.orders) {
      if (order.status == 'completed' || order.status == 'paid') {
        final dateKey = _getDateKey(order);
        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + order.totalAmount;
        dailyCount[dateKey] = (dailyCount[dateKey] ?? 0) + 1;
      }
    }

    final sortedKeys = dailyRevenue.keys.toList()..sort();
    return sortedKeys.map((key) {
      return ChartData(
        label: key,
        revenue: dailyRevenue[key] ?? 0,
        count: dailyCount[key] ?? 0,
      );
    }).toList();
  }

  String _getDateKey(OrderModel order) {
    // Extract date from invoice number or created_at
    // Assuming invoice format: INV-YYYYMMDD-XXXX
    final invoice = order.invoiceNumber;
    if (invoice.length >= 15) {
      return '${invoice.substring(4, 8)}-${invoice.substring(8, 10)}-${invoice.substring(10, 12)}';
    }
    return 'Unknown';
  }

  /// Set period filter
  void setPeriod(AnalyticsPeriod period) {
    _selectedPeriod = period;
    if (period != AnalyticsPeriod.custom) {
      _startDate = null;
      _endDate = null;
    }
    notifyListeners();
    fetchAnalytics();
  }

  /// Set custom date range
  void setCustomDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    _selectedPeriod = AnalyticsPeriod.custom;
    notifyListeners();
    fetchAnalytics();
  }

  /// Fetch analytics data
  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log.i('[OrderAnalyticsProvider] Fetching analytics for period: ${_selectedPeriod.value}');

      _analytics = await repository.getOrderAnalytics(
        period: _selectedPeriod,
        startDate: _startDate,
        endDate: _endDate,
      );

      _log.i('[OrderAnalyticsProvider] Analytics fetched: ${_analytics!.totalOrders} orders');
    } catch (e, st) {
      _log.e('[OrderAnalyticsProvider] Failed to fetch analytics', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Data class for chart display
class ChartData {
  final String label;
  final int revenue;
  final int count;

  const ChartData({
    required this.label,
    required this.revenue,
    required this.count,
  });
}
