import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/datasources/order_analytics_datasource.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/domain/repositories/order_analytics_repository.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/domain/repositories/order_analytics_repository_impl.dart';

/// Mock datasource untuk testing repository impl
class MockOrderAnalyticsDataSource implements OrderAnalyticsDataSource {
  OrderAnalyticsModel? mockResult;
  bool shouldFail = false;
  int callCount = 0;
  AnalyticsPeriod? lastPeriod;
  DateTime? lastStartDate;
  DateTime? lastEndDate;

  @override
  Future<OrderAnalyticsModel> getOrderAnalytics({
    required AnalyticsPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    callCount++;
    lastPeriod = period;
    lastStartDate = startDate;
    lastEndDate = endDate;

    if (shouldFail) throw Exception('Failed to fetch analytics');

    return mockResult ??
        const OrderAnalyticsModel(
          orders: [],
          totalOrders: 0,
          totalRevenue: 0,
          pendingCount: 0,
          completedCount: 0,
          cancelledCount: 0,
        );
  }
}

void main() {
  late MockOrderAnalyticsDataSource mockDataSource;
  late OrderAnalyticsRepositoryImpl repository;

  const tAnalytics = OrderAnalyticsModel(
    orders: [],
    totalOrders: 5,
    totalRevenue: 250000,
    pendingCount: 1,
    completedCount: 3,
    cancelledCount: 1,
  );

  setUp(() {
    mockDataSource = MockOrderAnalyticsDataSource();
    repository = OrderAnalyticsRepositoryImpl(dataSource: mockDataSource);
  });

  group('getOrderAnalytics', () {
    test('memanggil datasource.getOrderAnalytics() dengan period day', () async {
      mockDataSource.mockResult = tAnalytics;

      final result = await repository.getOrderAnalytics(
        period: AnalyticsPeriod.day,
      );

      expect(mockDataSource.callCount, 1);
      expect(mockDataSource.lastPeriod, AnalyticsPeriod.day);
      expect(result.totalOrders, 5);
      expect(result.totalRevenue, 250000);
    });

    test('memanggil datasource.getOrderAnalytics() dengan period week', () async {
      mockDataSource.mockResult = tAnalytics;

      await repository.getOrderAnalytics(
        period: AnalyticsPeriod.week,
      );

      expect(mockDataSource.lastPeriod, AnalyticsPeriod.week);
      expect(mockDataSource.lastStartDate, isNull);
      expect(mockDataSource.lastEndDate, isNull);
    });

    test('memanggil datasource.getOrderAnalytics() dengan period month', () async {
      mockDataSource.mockResult = tAnalytics;

      await repository.getOrderAnalytics(
        period: AnalyticsPeriod.month,
      );

      expect(mockDataSource.lastPeriod, AnalyticsPeriod.month);
    });

    test('meneruskan startDate dan endDate untuk period custom', () async {
      final startDate = DateTime(2026, 6, 1);
      final endDate = DateTime(2026, 6, 14);
      mockDataSource.mockResult = tAnalytics;

      await repository.getOrderAnalytics(
        period: AnalyticsPeriod.custom,
        startDate: startDate,
        endDate: endDate,
      );

      expect(mockDataSource.lastPeriod, AnalyticsPeriod.custom);
      expect(mockDataSource.lastStartDate, startDate);
      expect(mockDataSource.lastEndDate, endDate);
    });

    test('melempar exception jika datasource gagal', () async {
      mockDataSource.shouldFail = true;

      await expectLater(
        () => repository.getOrderAnalytics(period: AnalyticsPeriod.day),
        throwsA(isA<Exception>()),
      );
    });

    test('return OrderAnalyticsModel yang diterima dari datasource', () async {
      mockDataSource.mockResult = tAnalytics;

      final result = await repository.getOrderAnalytics(
        period: AnalyticsPeriod.day,
      );

      expect(result, tAnalytics);
    });
  });
}
