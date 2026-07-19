import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/payment_list_model.dart';


void main() {
  group('PaymentListModel', () {
    group('PaymentOrderModel', () {
      test('fromJson harus menghasilkan model yang benar', () {
        final json = {
          'id': 51,
          'invoice_number': 'INV-20260521-0357',
          'total_amount': 4000,
          'status': 'paid',
        };

        final result = PaymentOrderModel.fromJson(json);

        expect(result.id, 51);
        expect(result.invoiceNumber, 'INV-20260521-0357');
        expect(result.totalAmount, 4000);
        expect(result.status, 'paid');
      });

      test('toJson harus mengembalikan map yang benar', () {
        const model = PaymentOrderModel(
          id: 51,
          invoiceNumber: 'INV-20260521-0357',
          totalAmount: 4000,
          status: 'paid',
        );

        final json = model.toJson();

        expect(json['id'], 51);
        expect(json['invoice_number'], 'INV-20260521-0357');
        expect(json['total_amount'], 4000);
        expect(json['status'], 'paid');
      });
    });

    group('PaymentListItemModel', () {
      final tJson = {
        'id': 14,
        'order_id': 51,
        'payment_method': 'qris',
        'amount': 4000,
        'fee': 338,
        'total_payment': 4338,
        'payment_number': 'THIS.IS.JUST.AN.EXAMPLE...',
        'status': 'completed',
        'expired_at': '2026-05-21T08:55:07.000000Z',
        'completed_at': '2026-05-21T07:55:18.000000Z',
        'order': {
          'id': 51,
          'invoice_number': 'INV-20260521-0357',
          'total_amount': 4000,
          'status': 'paid',
        },
      };

      test('fromJson harus menghasilkan model yang benar', () {
        final result = PaymentListItemModel.fromJson(tJson);

        expect(result.id, 14);
        expect(result.orderId, 51);
        expect(result.paymentMethod, 'qris');
        expect(result.amount, 4000);
        expect(result.fee, 338);
        expect(result.totalPayment, 4338);
        expect(result.status, 'completed');
        expect(result.completedAt, isNotNull);
        expect(result.order.invoiceNumber, 'INV-20260521-0357');
      });

      test('completedAt null jika JSON null', () {
        final jsonWithNull = {...tJson, 'completed_at': null};
        final result = PaymentListItemModel.fromJson(jsonWithNull);

        expect(result.completedAt, isNull);
      });

      test('expiredAt di-parse sebagai DateTime', () {
        final result = PaymentListItemModel.fromJson(tJson);

        expect(result.expiredAt, isA<DateTime>());
        expect(result.expiredAt.year, 2026);
        expect(result.expiredAt.month, 5);
        expect(result.expiredAt.day, 21);
      });

      test('isCompleted true jika status completed', () {
        final result = PaymentListItemModel.fromJson(tJson);

        expect(result.isCompleted, true);
        expect(result.isPending, false);
      });

      test('isPending true jika status pending', () {
        final pendingJson = {...tJson, 'status': 'pending'};
        final result = PaymentListItemModel.fromJson(pendingJson);

        expect(result.isCompleted, false);
        expect(result.isPending, true);
      });

      test('isQris true untuk payment_method qris', () {
        final result = PaymentListItemModel.fromJson(tJson);
        expect(result.isQris, true);
      });

      test('isQris false untuk non-qris payment', () {
        final vaJson = {...tJson, 'payment_method': 'bni_va'};
        final result = PaymentListItemModel.fromJson(vaJson);
        expect(result.isQris, false);
      });
    });

    group('PaymentListModel', () {
      test('fromJson parse dua level data dengan benar', () {
        final json = {
          'success': true,
          'message': 'Payments retrieved successfully',
          'data': {
            'data': [
              {
                'id': 14,
                'order_id': 51,
                'payment_method': 'qris',
                'amount': 4000,
                'fee': 338,
                'total_payment': 4338,
                'payment_number': '123',
                'status': 'completed',
                'expired_at': '2026-05-21T08:55:07.000000Z',
                'completed_at': '2026-05-21T07:55:18.000000Z',
                'order': {
                  'id': 51,
                  'invoice_number': 'INV-1',
                  'total_amount': 4000,
                  'status': 'paid',
                },
              },
            ],
            'meta': {
              'current_page': 1,
              'last_page': 2,
              'per_page': 15,
              'total': 2,
            },
          },
        };

        final result = PaymentListModel.fromJson(json);

        expect(result.payments.length, 1);
        expect(result.currentPage, 1);
        expect(result.lastPage, 2);
        expect(result.total, 2);
      });

      test('hasNextPage true jika currentPage < lastPage', () {
        final json = {
          'data': {
            'data': [],
            'meta': {
              'current_page': 1,
              'last_page': 3,
              'total': 30,
            },
          },
        };

        final result = PaymentListModel.fromJson(json);

        expect(result.hasNextPage, true);
      });

      test('hasNextPage false jika currentPage == lastPage', () {
        final json = {
          'data': {
            'data': [],
            'meta': {
              'current_page': 1,
              'last_page': 1,
              'total': 2,
            },
          },
        };

        final result = PaymentListModel.fromJson(json);

        expect(result.hasNextPage, false);
      });
    });
  });
}