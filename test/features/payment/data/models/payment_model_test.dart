import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/payment/data/models/payment_model.dart';
import 'package:warmindo_purnama_flutter/core/constants/payment_constants.dart';

void main() {
  group('PaymentModel', () {
    final tJson = {
      'id': 13,
      'order_id': 50,
      'payment_method': 'qris',
      'amount': 4000,
      'fee': 338,
      'total_payment': 4338,
      'payment_number': 'THIS.IS.JUST.AN.EXAMPLE.FOR.SANDBOX...',
      'status': 'pending',
      'expired_at': '2026-05-21T08:49:14.000000Z',
      'completed_at': null,
    };

    final completedJson = {
      ...tJson,
      'status': 'completed',
      'completed_at': '2026-05-21T07:55:18.000000Z',
    };

    final expiredJson = {
      ...tJson,
      'status': 'expired',
    };

    test('fromJson menghasilkan model yang benar', () {
      final result = PaymentModel.fromJson(tJson);
      expect(result.id, 13);
      expect(result.orderId, 50);
      expect(result.paymentMethod, 'qris');
      expect(result.amount, 4000);
      expect(result.fee, 338);
      expect(result.totalPayment, 4338);
      expect(result.status, 'pending');
    });

    test('expiredAt di-parse sebagai DateTime', () {
      final result = PaymentModel.fromJson(tJson);
      expect(result.expiredAt, isA<DateTime>());
      expect(result.expiredAt.year, 2026);
    });

    test('completedAt null jika key null di JSON', () {
      final result = PaymentModel.fromJson(tJson);
      expect(result.completedAt, isNull);
    });

    test('completedAt tidak null jika key ada di JSON', () {
      final result = PaymentModel.fromJson(completedJson);
      expect(result.completedAt, isNotNull);
      expect(result.completedAt!.year, 2026);
    });

    test('isCompleted true jika status == completed', () {
      final result = PaymentModel.fromJson(completedJson);
      expect(result.isCompleted, true);
    });

    test('isExpired true jika status == expired', () {
      final result = PaymentModel.fromJson(expiredJson);
      expect(result.isExpired, true);
    });

    test('isExpired true jika DateTime.now() sudah lewat expiredAt', () {
      final pastJson = {
        ...tJson,
        'status': 'pending',
        'expired_at': '2020-01-01T00:00:00.000000Z',
      };
      final result = PaymentModel.fromJson(pastJson);
      expect(result.isExpired, true);
    });

    test('isPending true jika status == pending', () {
      final result = PaymentModel.fromJson(tJson);
      expect(result.isPending, true);
    });

    test('isQris true jika paymentMethod == qris', () {
      final result = PaymentModel.fromJson(tJson);
      expect(result.isQris, true);
    });

    test('isQris false jika paymentMethod == bni_va', () {
      final vaJson = {
        ...tJson,
        'payment_method': 'bni_va',
      };
      final result = PaymentModel.fromJson(vaJson);
      expect(result.isQris, false);
    });

    test('toJson mengembalikan map yang benar', () {
      final result = PaymentModel.fromJson(tJson);
      final json = result.toJson();
      expect(json['id'], 13);
      expect(json['order_id'], 50);
      expect(json['payment_method'], 'qris');
      expect(json['amount'], 4000);
    });

    test('props equality benar', () {
      final model1 = PaymentModel.fromJson(tJson);
      final model2 = PaymentModel.fromJson(tJson);
      expect(model1.props, equals(model2.props));
    });
  });

  group('PaymentMethod extension', () {
    test('qris value adalah qris', () {
      expect(PaymentMethod.qris.value, 'qris');
    });

    test('bniVa value adalah bni_va', () {
      expect(PaymentMethod.bniVa.value, 'bni_va');
    });

    test('qris label adalah QRIS', () {
      expect(PaymentMethod.qris.label, 'QRIS');
    });

    test('bniVa label adalah BNI Virtual Account', () {
      expect(PaymentMethod.bniVa.label, 'BNI Virtual Account');
    });

    test('qris isQris adalah true', () {
      expect(PaymentMethod.qris.isQris, true);
    });

    test('bniVa isQris adalah false', () {
      expect(PaymentMethod.bniVa.isQris, false);
    });

    test('paymentMethodFromString parsing benar', () {
      expect(paymentMethodFromString('qris'), PaymentMethod.qris);
      expect(paymentMethodFromString('bni_va'), PaymentMethod.bniVa);
      expect(paymentMethodFromString('bri_va'), PaymentMethod.briVa);
    });

    test('paymentMethodFromString fallback ke qris untuk string tidak dikenal', () {
      expect(paymentMethodFromString('unknown'), PaymentMethod.qris);
      expect(paymentMethodFromString(''), PaymentMethod.qris);
    });
  });
}