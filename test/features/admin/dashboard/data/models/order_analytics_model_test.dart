import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/order_analytics_model.dart';

void main() {
  group('OrderAnalyticsModel', () {
    group('fromJson', () {
      test('harus parse data dengan benar dari JSON lengkap', () {
        final json = {
          'data': {
            'data': [
              {
                'id': 1,
                'invoice_number': 'INV-20260614-0001',
                'user_id': 2,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 50000,
                'total_amount': 55000,
                'status': 'completed',
                'notes': null,
                'order_items': [],
              },
              {
                'id': 2,
                'invoice_number': 'INV-20260614-0002',
                'user_id': 3,
                'restaurant_table_id': 1,
                'order_type_id': 2,
                'subtotal': 30000,
                'total_amount': 33000,
                'status': 'pending',
                'notes': null,
                'order_items': [],
              },
              {
                'id': 3,
                'invoice_number': 'INV-20260614-0003',
                'user_id': 4,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 20000,
                'total_amount': 22000,
                'status': 'cancelled',
                'notes': null,
                'order_items': [],
              },
            ],
            'meta': {
              'current_page': 1,
              'total': 3,
            },
          },
        };

        final model = OrderAnalyticsModel.fromJson(json);

        expect(model.orders.length, 3);
        expect(model.totalOrders, 3);
        expect(model.completedCount, 1);
        expect(model.pendingCount, 1);
        expect(model.cancelledCount, 1);
        expect(model.totalRevenue, 55000);
      });

      test('harus hitung totalRevenue hanya dari order completed/paid', () {
        final json = {
          'data': {
            'data': [
              {
                'id': 1,
                'invoice_number': 'INV-20260614-0001',
                'user_id': 1,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 100000,
                'total_amount': 110000,
                'status': 'completed',
                'notes': null,
                'order_items': [],
              },
              {
                'id': 2,
                'invoice_number': 'INV-20260614-0002',
                'user_id': 1,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 50000,
                'total_amount': 55000,
                'status': 'paid',
                'notes': null,
                'order_items': [],
              },
              {
                'id': 3,
                'invoice_number': 'INV-20260614-0003',
                'user_id': 1,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 30000,
                'total_amount': 33000,
                'status': 'pending',
                'notes': null,
                'order_items': [],
              },
            ],
            'meta': {},
          },
        };

        final model = OrderAnalyticsModel.fromJson(json);

        // totalRevenue hanya dari 'completed' dan 'paid'
        expect(model.totalRevenue, 165000);
        expect(model.completedCount, 2);
        expect(model.pendingCount, 1);
        expect(model.cancelledCount, 0);
      });

      test('harus handle data kosong', () {
        final json = {
          'data': {
            'data': <dynamic>[],
            'meta': {},
          },
        };

        final model = OrderAnalyticsModel.fromJson(json);

        expect(model.orders.isEmpty, true);
        expect(model.totalOrders, 0);
        expect(model.totalRevenue, 0);
        expect(model.pendingCount, 0);
        expect(model.completedCount, 0);
        expect(model.cancelledCount, 0);
      });

      test('harus hitung multiple orders dengan status sama', () {
        final json = {
          'data': {
            'data': [
              {
                'id': 1,
                'invoice_number': 'INV-20260614-0001',
                'user_id': 1,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 25000,
                'total_amount': 27500,
                'status': 'completed',
                'notes': null,
                'order_items': [],
              },
              {
                'id': 2,
                'invoice_number': 'INV-20260614-0002',
                'user_id': 2,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 35000,
                'total_amount': 38500,
                'status': 'completed',
                'notes': null,
                'order_items': [],
              },
              {
                'id': 3,
                'invoice_number': 'INV-20260614-0003',
                'user_id': 3,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 15000,
                'total_amount': 16500,
                'status': 'cancelled',
                'notes': null,
                'order_items': [],
              },
              {
                'id': 4,
                'invoice_number': 'INV-20260614-0004',
                'user_id': 4,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 10000,
                'total_amount': 11000,
                'status': 'cancelled',
                'notes': null,
                'order_items': [],
              },
            ],
            'meta': {},
          },
        };

        final model = OrderAnalyticsModel.fromJson(json);

        expect(model.totalOrders, 4);
        expect(model.completedCount, 2);
        expect(model.cancelledCount, 2);
        expect(model.pendingCount, 0);
        expect(model.totalRevenue, 27500 + 38500);
      });
    });

    group('Equatable props', () {
      test('dua model dengan data sama harus equal', () {
        final json = {
          'data': {
            'data': [
              {
                'id': 1,
                'invoice_number': 'INV-20260614-0001',
                'user_id': 1,
                'restaurant_table_id': null,
                'order_type_id': 1,
                'subtotal': 50000,
                'total_amount': 55000,
                'status': 'completed',
                'notes': null,
                'order_items': [],
              },
            ],
            'meta': {},
          },
        };

        final model1 = OrderAnalyticsModel.fromJson(json);
        final model2 = OrderAnalyticsModel.fromJson(json);

        expect(model1, model2);
      });
    });
  });

  group('AnalyticsPeriod', () {
    test('value dan label harus benar untuk setiap periode', () {
      expect(AnalyticsPeriod.day.value, 'day');
      expect(AnalyticsPeriod.day.label, 'Hari Ini');

      expect(AnalyticsPeriod.week.value, 'week');
      expect(AnalyticsPeriod.week.label, 'Minggu Ini');

      expect(AnalyticsPeriod.month.value, 'month');
      expect(AnalyticsPeriod.month.label, 'Bulan Ini');

      expect(AnalyticsPeriod.custom.value, 'custom');
      expect(AnalyticsPeriod.custom.label, 'Kustom');
    });

    test('harus ada 4 periode', () {
      expect(AnalyticsPeriod.values.length, 4);
    });
  });
}
