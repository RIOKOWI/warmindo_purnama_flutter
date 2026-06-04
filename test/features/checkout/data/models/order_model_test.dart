import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_item_model.dart';

void main() {
  group('OrderModel', () {
    final tJson = {
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
          'updated_at': '2026-05-17T23:49:55.000000Z',
        },
        {
          'id': 40,
          'order_id': 49,
          'product_id': 94,
          'product_name': 'Mie Dok-Dok',
          'quantity': 4,
          'product_price': 1000,
          'subtotal': 4000,
          'created_at': '2026-05-17T23:49:55.000000Z',
          'updated_at': '2026-05-17T23:49:55.000000Z',
        },
      ],
      'created_at': '2026-05-17T23:49:55.000000Z',
      'updated_at': '2026-05-17T23:49:55.000000Z',
    };

    test('fromJson menghasilkan model dengan orderItems yang benar', () {
      final result = OrderModel.fromJson(tJson);
      expect(result.id, 49);
      expect(result.invoiceNumber, 'INV-20260517-5928');
      expect(result.orderItems.length, 2);
      expect(result.orderItems[0].productName, 'Nasi Omelette');
    });

    test('orderItems berisi list OrderItemModel yang benar', () {
      final result = OrderModel.fromJson(tJson);
      expect(result.orderItems[0], isA<OrderItemModel>());
      expect(result.orderItems[0].id, 39);
      expect(result.orderItems[0].quantity, 4);
    });

    test('restaurantTableId nullable — fromJson tanpa key ini tidak crash', () {
      final jsonWithoutTable = {
        ...tJson,
        'restaurant_table_id': null,
      };
      final result = OrderModel.fromJson(jsonWithoutTable);
      expect(result.restaurantTableId, isNull);
    });

    test('notes nullable — fromJson tanpa key ini tidak crash', () {
      final jsonWithoutNotes = {
        ...tJson,
        'notes': null,
      };
      final result = OrderModel.fromJson(jsonWithoutNotes);
      expect(result.notes, isNull);
    });

    test('toJson mengembalikan map yang benar', () {
      final model = OrderModel.fromJson(tJson);
      final json = model.toJson();
      expect(json['id'], 49);
      expect(json['invoice_number'], 'INV-20260517-5928');
      expect(json['order_items'], isA<List>());
    });

    test('props equality benar', () {
      final model1 = OrderModel.fromJson(tJson);
      final model2 = OrderModel.fromJson(tJson);
      expect(model1.props, equals(model2.props));
    });
  });

  group('OrderItemModel', () {
    final tJson = {
      'id': 39,
      'order_id': 49,
      'product_id': 93,
      'product_name': 'Nasi Omelette',
      'quantity': 4,
      'product_price': 1000,
      'subtotal': 4000,
    };

    test('fromJson menghasilkan model yang benar', () {
      final result = OrderItemModel.fromJson(tJson);
      expect(result.id, 39);
      expect(result.orderId, 49);
      expect(result.productId, 93);
      expect(result.productName, 'Nasi Omelette');
      expect(result.quantity, 4);
      expect(result.productPrice, 1000);
      expect(result.subtotal, 4000);
    });

    test('toJson mengembalikan map yang benar', () {
      final model = OrderItemModel.fromJson(tJson);
      final json = model.toJson();
      expect(json['id'], 39);
      expect(json['product_name'], 'Nasi Omelette');
    });
  });
}
