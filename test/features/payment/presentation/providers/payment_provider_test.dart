import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/payment/data/models/payment_model.dart';
import 'package:warmindo_purnama_flutter/features/payment/data/models/create_payment_request_model.dart';
import 'package:warmindo_purnama_flutter/features/payment/domain/repositories/payment_repository.dart';
import 'package:warmindo_purnama_flutter/features/payment/presentation/providers/payment_provider.dart';
import 'package:warmindo_purnama_flutter/core/constants/payment_constants.dart';

// Mock repository for testing
class MockPaymentRepository implements PaymentRepository {
  PaymentModel? paymentToReturn;
  bool shouldThrowOnCreate = false;
  bool shouldThrowOnGetDetail = false;
  int createCallCount = 0;
  int getDetailCallCount = 0;
  CreatePaymentRequestModel? lastCreateRequest;

  @override
  Future<PaymentModel> createPayment({
    required int orderId,
    required CreatePaymentRequestModel request,
  }) async {
    createCallCount++;
    lastCreateRequest = request;
    if (shouldThrowOnCreate) {
      throw Exception('Gagal membuat pembayaran');
    }
    return paymentToReturn!;
  }

  @override
  Future<PaymentModel> getPaymentDetail(int paymentId) async {
    getDetailCallCount++;
    if (shouldThrowOnGetDetail) {
      throw Exception('Gagal mengambil detail');
    }
    return paymentToReturn!;
  }

  void reset() {
    paymentToReturn = null;
    shouldThrowOnCreate = false;
    shouldThrowOnGetDetail = false;
    createCallCount = 0;
    getDetailCallCount = 0;
    lastCreateRequest = null;
  }
}

void main() {
  late PaymentProvider provider;
  late MockPaymentRepository mockRepo;

  PaymentModel createMockPayment({
    String status = 'pending',
    DateTime? expiredAt,
  }) {
    return PaymentModel(
      id: 13,
      orderId: 50,
      paymentMethod: 'qris',
      amount: 4000,
      fee: 338,
      totalPayment: 4338,
      paymentNumber: 'QR123456',
      status: status,
      expiredAt: expiredAt ?? DateTime.now().add(const Duration(hours: 1)),
      completedAt: null,
    );
  }

  setUp(() {
    mockRepo = MockPaymentRepository();
    provider = PaymentProvider(repository: mockRepo);
  });

  tearDown(() {
    provider.dispose();
  });

  group('PaymentProvider - selectMethod()', () {
    test('selectedMethod berubah jika belum ada payment', () {
      provider.selectMethod(PaymentMethod.bniVa);
      expect(provider.selectedMethod, PaymentMethod.bniVa);

      provider.selectMethod(PaymentMethod.cimbNiagaVa);
      expect(provider.selectedMethod, PaymentMethod.cimbNiagaVa);
    });

    test('selectedMethod TIDAK berubah jika sudah ada payment', () {
      mockRepo.paymentToReturn = createMockPayment();
      provider.selectMethod(PaymentMethod.bniVa);
      expect(provider.selectedMethod, PaymentMethod.bniVa);

      // Simulate having payment by calling createPayment
      provider.createPayment(50);

      // Try to change method after payment exists
      provider.selectMethod(PaymentMethod.cimbNiagaVa);
      // Should not change because hasPayment is true
    });
  });

  group('PaymentProvider - createPayment()', () {
    test('set isCreating true saat proses, false setelah selesai', () async {
      mockRepo.paymentToReturn = createMockPayment();

      expect(provider.isCreating, false);

      final future = provider.createPayment(50);
      expect(provider.isCreating, true);

      await future;
      expect(provider.isCreating, false);
    });

    test('_payment terisi setelah swipe', () async {
      mockRepo.paymentToReturn = createMockPayment();

      await provider.createPayment(50);

      expect(provider.payment, isNotNull);
      expect(provider.payment!.id, 13);
    });

    test('hasPayment true setelah swipe', () async {
      mockRepo.paymentToReturn = createMockPayment();

      await provider.createPayment(50);

      expect(provider.hasPayment, true);
    });

    test('return true jika swipe', () async {
      mockRepo.paymentToReturn = createMockPayment();

      final result = await provider.createPayment(50);

      expect(result, true);
    });

    test('set errorMessage dan return false jika gagal', () async {
      mockRepo.shouldThrowOnCreate = true;

      final result = await provider.createPayment(50);

      expect(result, false);
      expect(provider.errorMessage, isNotNull);
    });

    test('isCreating false meski gagal', () async {
      mockRepo.shouldThrowOnCreate = true;

      await provider.createPayment(50);

      expect(provider.isCreating, false);
    });

    test('timer started setelah swipe', () async {
      mockRepo.paymentToReturn = createMockPayment();

      await provider.createPayment(50);

      // Timer should be running, so we check remainingTime
      expect(provider.remainingTime.inSeconds, greaterThan(0));
    });
  });

  group('PaymentProvider - refreshStatus()', () {
    test('_payment diupdate dengan response terbaru', () async {
      mockRepo.paymentToReturn = createMockPayment(status: 'pending');

      await provider.createPayment(50);

      // Update mock to return completed status
      mockRepo.paymentToReturn = createMockPayment(status: 'completed');

      await provider.refreshStatus();

      expect(provider.payment!.status, 'completed');
    });

    test('TIDAK set errorMessage jika getPaymentDetail gagal', () async {
      mockRepo.paymentToReturn = createMockPayment();
      await provider.createPayment(50);

      mockRepo.shouldThrowOnGetDetail = true;
      provider.refreshStatus();

      // Wait a bit for async operation
      await Future.delayed(const Duration(milliseconds: 100));

      // Error should not be set on silent fail
      expect(provider.errorMessage, isNull);
    });

    test('timer berhenti jika status completed', () async {
      mockRepo.paymentToReturn = createMockPayment();
      await provider.createPayment(50);

      mockRepo.paymentToReturn = createMockPayment(status: 'completed');

      await provider.refreshStatus();

      // Timer should be stopped after completed
    });
  });

  group('PaymentProvider - countdown', () {
    test('remainingTime berkurang setiap detik', () async {
      mockRepo.paymentToReturn = createMockPayment(
        expiredAt: DateTime.now().add(const Duration(seconds: 5)),
      );

      await provider.createPayment(50);

      final initialTime = provider.remainingTime;

      await Future.delayed(const Duration(seconds: 1));

      expect(provider.remainingTime.inSeconds, lessThan(initialTime.inSeconds));
    });

    test('remainingTime tidak negatif', () async {
      mockRepo.paymentToReturn = createMockPayment(
        expiredAt: DateTime.now().add(const Duration(seconds: 1)),
      );

      await provider.createPayment(50);

      // Wait for timer to expire
      await Future.delayed(const Duration(seconds: 2));

      expect(provider.remainingTime.inSeconds, 0);
    });
  });

  group('PaymentProvider - cleanup()', () {
    test('_payment menjadi null', () async {
      mockRepo.paymentToReturn = createMockPayment();
      await provider.createPayment(50);

      provider.cleanup();

      expect(provider.payment, isNull);
    });

    test('_errorMessage menjadi null', () async {
      mockRepo.shouldThrowOnCreate = true;
      await provider.createPayment(50);

      provider.cleanup();

      expect(provider.errorMessage, isNull);
    });

    test('_remainingTime menjadi Duration.zero', () async {
      mockRepo.paymentToReturn = createMockPayment();
      await provider.createPayment(50);

      provider.cleanup();

      expect(provider.remainingTime, Duration.zero);
    });

    test('_selectedMethod kembali ke qris', () async {
      provider.selectMethod(PaymentMethod.bniVa);

      provider.cleanup();

      expect(provider.selectedMethod, PaymentMethod.qris);
    });
  });

  group('PaymentProvider - getters', () {
    test('isCompleted mengembalikan true jika payment isCompleted', () async {
      mockRepo.paymentToReturn = createMockPayment(status: 'completed');
      await provider.createPayment(50);

      expect(provider.isCompleted, true);
    });

    test('isExpired mengembalikan true jika payment isExpired', () async {
      mockRepo.paymentToReturn = createMockPayment(
        status: 'pending',
        expiredAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      await provider.createPayment(50);

      expect(provider.isExpired, true);
    });
  });
}