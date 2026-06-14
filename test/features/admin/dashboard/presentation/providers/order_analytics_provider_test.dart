import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/domain/repositories/order_analytics_repository.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/order_analytics_provider.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';

/// Mock repository untuk testing provider
class MockOrderAnalyticsRepository implements OrderAnalyticsRepository {
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

/// Helper untuk membuat OrderModel dummy
OrderModel _makeOrder({
  required int id,
  required String invoiceNumber,
  required String status,
  int totalAmount = 0,
}) {
  return OrderModel(
    id: id,
    invoiceNumber: invoiceNumber,
    userId: 1,
    orderTypeId: 1,
    subtotal: totalAmount,
    totalAmount: totalAmount,
    status: status,
    orderItems: [],
  );
}

void main() {
  late MockOrderAnalyticsRepository mockRepository;
  late OrderAnalyticsProvider provider;

  setUp(() {
    mockRepository = MockOrderAnalyticsRepository();
    provider = OrderAnalyticsProvider(repository: mockRepository);
  });

  group('initial state', () {
    test('analytics null saat awal', () {
      expect(provider.analytics, isNull);
    });

    test('isLoading false saat awal', () {
      expect(provider.isLoading, false);
    });

    test('selectedPeriod day saat awal', () {
      expect(provider.selectedPeriod, AnalyticsPeriod.day);
    });

    test('error null saat awal', () {
      expect(provider.error, isNull);
    });

    test('chartData kosong jika analytics null', () {
      expect(provider.chartData, isEmpty);
    });
  });

  group('fetchAnalytics', () {
    test('isLoading true saat fetch berlangsung', () async {
      mockRepository.mockResult = const OrderAnalyticsModel(
        orders: [],
        totalOrders: 0,
        totalRevenue: 0,
        pendingCount: 0,
        completedCount: 0,
        cancelledCount: 0,
      );

      final future = provider.fetchAnalytics();
      expect(provider.isLoading, true);

      await future;
      expect(provider.isLoading, false);
    });

    test('analytics terisi setelah fetch sukses', () async {
      const tAnalytics = OrderAnalyticsModel(
        orders: [],
        totalOrders: 5,
        totalRevenue: 275000,
        pendingCount: 1,
        completedCount: 3,
        cancelledCount: 1,
      );
      mockRepository.mockResult = tAnalytics;

      await provider.fetchAnalytics();

      expect(provider.analytics, isNotNull);
      expect(provider.analytics!.totalOrders, 5);
      expect(provider.analytics!.totalRevenue, 275000);
    });

    test('error terisi jika fetch gagal', () async {
      mockRepository.shouldFail = true;

      await provider.fetchAnalytics();

      expect(provider.analytics, isNull);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Failed to fetch analytics'));
    });

    test('error direset sebelum fetch baru', () async {
      mockRepository.shouldFail = true;
      await provider.fetchAnalytics();
      expect(provider.error, isNotNull);

      // Reset mock dan fetch lagi
      mockRepository.shouldFail = false;
      mockRepository.mockResult = const OrderAnalyticsModel(
        orders: [],
        totalOrders: 0,
        totalRevenue: 0,
        pendingCount: 0,
        completedCount: 0,
        cancelledCount: 0,
      );
      await provider.fetchAnalytics();

      expect(provider.error, isNull);
    });

    test('memanggil repository dengan period yang dipilih', () async {
      await provider.fetchAnalytics();

      expect(mockRepository.lastPeriod, AnalyticsPeriod.day);
    });
  });

  group('setPeriod', () {
    test('mengubah selectedPeriod dan memanggil fetchAnalytics', () async {
      provider.setPeriod(AnalyticsPeriod.week);
      // Tunggu fetchAnalytics yang dipanggil secara internal
      await Future.delayed(Duration.zero);

      expect(provider.selectedPeriod, AnalyticsPeriod.week);
      expect(mockRepository.lastPeriod, AnalyticsPeriod.week);
    });

    test('mereset startDate dan endDate saat period bukan custom', () async {
      // Set custom date range dulu
      provider.setCustomDateRange(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 14),
      );
      expect(provider.startDate, isNotNull);
      expect(provider.endDate, isNotNull);

      // Ganti ke period bukan custom
      provider.setPeriod(AnalyticsPeriod.month);
      await Future.delayed(Duration.zero);

      expect(provider.startDate, isNull);
      expect(provider.endDate, isNull);
    });

    test('tidak mereset tanggal jika period custom', () async {
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 6, 14);

      provider.setCustomDateRange(start, end);

      // setCustomDateRange set period ke custom, verifikasi tanggal tersimpan
      expect(provider.selectedPeriod, AnalyticsPeriod.custom);
      expect(provider.startDate, start);
      expect(provider.endDate, end);
    });
  });

  group('setCustomDateRange', () {
    test('set startDate, endDate, dan period ke custom', () async {
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 6, 30);

      provider.setCustomDateRange(start, end);

      expect(provider.selectedPeriod, AnalyticsPeriod.custom);
      expect(provider.startDate, start);
      expect(provider.endDate, end);
    });

    test('memanggil fetchAnalytics dengan startDate dan endDate', () async {
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 6, 30);

      provider.setCustomDateRange(start, end);
      // Tunggu fetch selesai
      await Future.delayed(Duration.zero);

      expect(mockRepository.lastStartDate, start);
      expect(mockRepository.lastEndDate, end);
    });
  });

  group('chartData', () {
    test('kosong jika analytics null', () {
      expect(provider.chartData, isEmpty);
    });

    test('kosong jika tidak ada order completed/paid', () async {
      mockRepository.mockResult = OrderAnalyticsModel(
        orders: [
          _makeOrder(
            id: 1,
            invoiceNumber: 'INV-20260614-0001',
            status: 'pending',
            totalAmount: 55000,
          ),
        ],
        totalOrders: 1,
        totalRevenue: 0,
        pendingCount: 1,
        completedCount: 0,
        cancelledCount: 0,
      );

      await provider.fetchAnalytics();

      expect(provider.chartData, isEmpty);
    });

    test('mengelompokkan revenue per tanggal dari invoice number', () async {
      // Invoice format: INV-YYYYMMDD-XXXX
      mockRepository.mockResult = OrderAnalyticsModel(
        orders: [
          _makeOrder(
            id: 1,
            invoiceNumber: 'INV-20260614-0001',
            status: 'completed',
            totalAmount: 55000,
          ),
          _makeOrder(
            id: 2,
            invoiceNumber: 'INV-20260614-0002',
            status: 'completed',
            totalAmount: 33000,
          ),
          _makeOrder(
            id: 3,
            invoiceNumber: 'INV-20260613-0001',
            status: 'paid',
            totalAmount: 22000,
          ),
        ],
        totalOrders: 3,
        totalRevenue: 110000,
        pendingCount: 0,
        completedCount: 3,
        cancelledCount: 0,
      );

      await provider.fetchAnalytics();

      final chartData = provider.chartData;

      // Harus ada 2 tanggal berbeda
      expect(chartData.length, 2);

      // Data diurutkan by label (tanggal)
      expect(chartData[0].label, '2026-06-13');
      expect(chartData[0].revenue, 22000);
      expect(chartData[0].count, 1);

      expect(chartData[1].label, '2026-06-14');
      expect(chartData[1].revenue, 88000); // 55000 + 33000
      expect(chartData[1].count, 2);
    });

    test('order cancelled tidak masuk chartData', () async {
      mockRepository.mockResult = OrderAnalyticsModel(
        orders: [
          _makeOrder(
            id: 1,
            invoiceNumber: 'INV-20260614-0001',
            status: 'completed',
            totalAmount: 55000,
          ),
          _makeOrder(
            id: 2,
            invoiceNumber: 'INV-20260614-0002',
            status: 'cancelled',
            totalAmount: 33000,
          ),
        ],
        totalOrders: 2,
        totalRevenue: 55000,
        pendingCount: 0,
        completedCount: 1,
        cancelledCount: 1,
      );

      await provider.fetchAnalytics();

      final chartData = provider.chartData;
      expect(chartData.length, 1);
      expect(chartData[0].revenue, 55000);
    });
  });

  group('ChartData', () {
    test('menyimpan label, revenue, dan count dengan benar', () {
      const data = ChartData(
        label: '2026-06-14',
        revenue: 100000,
        count: 3,
      );

      expect(data.label, '2026-06-14');
      expect(data.revenue, 100000);
      expect(data.count, 3);
    });
  });
}
