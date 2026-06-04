import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/order/data/models/order_list_model.dart';

void main() {
  group('OrderListModel', () {
    final tJson = {
      'success': true,
      'message': 'Orders retrieved successfully',
      'data': {
        'data': [
          {
            'id': 49,
            'invoice_number': 'INV-20260517-5928',
            'user_id': 310,
            'customer_name': null,
            'restaurant_table_id': 64,
            'order_type_id': 55,
            'subtotal': 12000,
            'total_amount': 12000,
            'status': 'pending',
            'notes': 'otw',
            'order_items': [
              {
                'id': 39,
                'order_id': 49,
                'product_id': 93,
                'product_name': 'Nasi Omelette',
                'quantity': 4,
                'product_price': 1000,
                'subtotal': 4000,
                'created_at': '2026-05-17T23:49:55.000000Z',
                'updated_at': '2026-05-17T23:49:55.000000Z'
              }
            ],
            'payment': null,
            'created_at': '2026-05-17T23:49:55.000000Z',
            'updated_at': '2026-05-17T23:49:55.000000Z'
          },
          {
            'id': 50,
            'invoice_number': 'INV-20260521-4862',
            'user_id': 312,
            'customer_name': null,
            'restaurant_table_id': 64,
            'order_type_id': 55,
            'subtotal': 4000,
            'total_amount': 4000,
            'status': 'cancelled',
            'notes': 'otw',
            'order_items': [
              {
                'id': 42,
                'order_id': 50,
                'product_id': 95,
                'product_name': 'Mie Goreng',
                'quantity': 4,
                'product_price': 1000,
                'subtotal': 4000,
                'created_at': '2026-05-21T07:43:01.000000Z',
                'updated_at': '2026-05-21T07:43:01.000000Z'
              }
            ],
            'payment': null,
            'created_at': '2026-05-21T07:43:01.000000Z',
            'updated_at': '2026-05-21T07:43:01.000000Z'
          }
        ],
        'links': {},
        'meta': {
          'current_page': 1,
          'from': 1,
          'last_page': 2,
          'path': 'http://127.0.0.1:8000/api/v1/orders',
          'per_page': 15,
          'to': 3,
          'total': 25
        }
      }
    };

    test('fromJson menghasilkan model dengan orders yang benar', () {
      final result = OrderListModel.fromJson(tJson);

      expect(result.orders.length, 2);
      expect(result.orders[0].id, 49);
      expect(result.orders[0].invoiceNumber, 'INV-20260517-5928');
      expect(result.orders[0].status, 'pending');
      expect(result.orders[0].orderItems.length, 1);
      expect(result.orders[0].orderItems[0].productName, 'Nasi Omelette');
    });

    test('currentPage, lastPage, total terisi dari meta', () {
      final result = OrderListModel.fromJson(tJson);

      expect(result.currentPage, 1);
      expect(result.lastPage, 2);
      expect(result.total, 25);
    });

    test('hasNextPage true jika currentPage < lastPage', () {
      final result = OrderListModel.fromJson(tJson);

      expect(result.hasNextPage, true);
    });

    test('hasNextPage false jika currentPage == lastPage', () {
      final singlePageJson = {
        'success': true,
        'message': 'Orders retrieved successfully',
        'data': {
          'data': [],
          'links': {},
          'meta': {
            'current_page': 1,
            'from': 1,
            'last_page': 1,
            'path': 'http://127.0.0.1:8000/api/v1/orders',
            'per_page': 15,
            'to': 0,
            'total': 0
          }
        }
      };

      final result = OrderListModel.fromJson(singlePageJson);

      expect(result.currentPage, 1);
      expect(result.lastPage, 1);
      expect(result.hasNextPage, false);
    });

    test('orders kosong jika data["data"] kosong', () {
      final emptyJson = {
        'success': true,
        'message': 'Orders retrieved successfully',
        'data': {
          'data': [],
          'links': {},
          'meta': {
            'current_page': 1,
            'from': 1,
            'last_page': 1,
            'path': 'http://127.0.0.1:8000/api/v1/orders',
            'per_page': 15,
            'to': 0,
            'total': 0
          }
        }
      };

      final result = OrderListModel.fromJson(emptyJson);

      expect(result.orders, isEmpty);
    });
  });
}