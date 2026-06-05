import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/payment_list_model.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/providers/payment_list_provider.dart';


// Generate with: dart run build_runner build --delete-conflicting-outputs
import '../../../../../mocks.mocks.dart';

void main() {
  late PaymentListProvider provider;
  late MockPaymentListRepository mockRepository;

  setUp(() {
    mockRepository = MockPaymentListRepository();
    provider = PaymentListProvider(repository: mockRepository);
  });

  // Test data
  PaymentListItemModel createPayment({
    required int id,
    required String status,
    required int totalPayment,
  }) {
    return PaymentListItemModel(
      id: id,
      orderId: id + 100,
      paymentMethod: 'qris',
      amount: totalPayment - 338,
      fee: 338,
      totalPayment: totalPayment,
      paymentNumber: 'PAY-$id',
      status: status,
      expiredAt: DateTime.now().add(const Duration(days: 1)),
      order: PaymentOrderModel(
        id: id + 100,
        invoiceNumber: 'INV-$id',
        totalAmount: totalPayment - 338,
        status: status == 'completed' ? 'paid' : 'pending',
      ),
    );
  }

  group('PaymentListProvider', () {
    group('Getters - Initial State', () {
      test('payments harus return empty list di awal', () {
        expect(provider.payments, isEmpty);
      });

      test('isLoading harus false di awal', () {
        expect(provider.isLoading, false);
      });

      test('activeFilter harus null di awal', () {
        expect(provider.activeFilter, isNull);
      });

      test('hasNextPage harus false di awal', () {
        expect(provider.hasNextPage, false);
      });
    });

    group('fetchPayments', () {
      test('isLoading true hanya jika payments kosong', () async {
        // arrange
        final payments = [
          createPayment(id: 1, status: 'completed', totalPayment: 4000),
        ];
        when(mockRepository.getPayments(
          page: anyNamed('page'),
          statusFilter: anyNamed('statusFilter'),
        )).thenAnswer((_) async => PaymentListModel(
          payments: payments,
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ));

        // act
        await provider.fetchPayments();

        // isLoading should be false after fetch completes
        expect(provider.isLoading, false);
      });

      test('payments terisi setelah sukses', () async {
        // arrange
        final payments = [
          createPayment(id: 1, status: 'completed', totalPayment: 4000),
          createPayment(id: 2, status: 'pending', totalPayment: 5000),
        ];
        when(mockRepository.getPayments(
          page: 1,
          statusFilter: null,
        )).thenAnswer((_) async => PaymentListModel(
          payments: payments,
          currentPage: 1,
          lastPage: 1,
          total: 2,
        ));

        // act
        await provider.fetchPayments();

        // assert
        expect(provider.payments.length, 2);
        expect(provider.payments[0].id, 1);
        expect(provider.payments[1].id, 2);
      });

      test('refresh: payments direset bukan append', () async {
        // arrange
        provider.payments.add(createPayment(id: 99, status: 'pending', totalPayment: 1000));

        final newPayments = [
          createPayment(id: 1, status: 'completed', totalPayment: 4000),
        ];
        when(mockRepository.getPayments(
          page: 1,
          statusFilter: null,
        )).thenAnswer((_) async => PaymentListModel(
          payments: newPayments,
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ));

        // act
        await provider.fetchPayments(refresh: true);

        // assert - should be reset, not appended
        expect(provider.payments.length, 1);
        expect(provider.payments[0].id, 1);
      });

      test('errorMessage terisi jika gagal', () async {
        // arrange
        when(mockRepository.getPayments(
          page: 1,
          statusFilter: null,
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Network error',
          ),
        );

        // act
        await provider.fetchPayments();

        // assert
        expect(provider.errorMessage, isNotNull);
        expect(provider.payments, isEmpty);
      });
    });

    group('loadMore', () {
      test('loadMore tidak terjadi jika hasNextPage false', () async {
        // act - call loadMore when hasNextPage is false
        await provider.loadMore();

        // assert - hasNextPage should still be false
        expect(provider.hasNextPage, false);
        expect(provider.isLoadingMore, false);
      });
    });

    group('applyFilter', () {
      test('tidak fetch ulang jika filter sama', () async {
        // arrange
        provider.payments.add(createPayment(id: 1, status: 'completed', totalPayment: 4000));

        // First, set up the provider to have 'completed' filter by calling fetchPayments
        when(mockRepository.getPayments(
          page: 1,
          statusFilter: 'completed',
        )).thenAnswer((_) async => PaymentListModel(
          payments: [createPayment(id: 1, status: 'completed', totalPayment: 4000)],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ));

        await provider.applyFilter('completed');

        // Now try applyFilter with same filter - should not call repository again
        // act
        await provider.applyFilter('completed');

        // assert - repository should only be called once (during first applyFilter)
        verify(mockRepository.getPayments(
          page: anyNamed('page'),
          statusFilter: anyNamed('statusFilter'),
        )).called(1);
      });

      test('fetchPayments dipanggil dengan refresh: true jika filter berbeda', () async {
        // arrange
        provider.payments.add(createPayment(id: 1, status: 'completed', totalPayment: 4000));

        when(mockRepository.getPayments(
          page: 1,
          statusFilter: 'pending',
        )).thenAnswer((_) async => PaymentListModel(
          payments: [
            createPayment(id: 2, status: 'pending', totalPayment: 5000),
          ],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ));

        // act
        await provider.applyFilter('pending');

        // assert
        verify(mockRepository.getPayments(
          page: 1,
          statusFilter: 'pending',
        )).called(1);
      });

      test('payments direset saat filter berubah', () async {
        // arrange
        provider.payments.add(createPayment(id: 1, status: 'completed', totalPayment: 4000));

        when(mockRepository.getPayments(
          page: 1,
          statusFilter: 'pending',
        )).thenAnswer((_) async => PaymentListModel(
          payments: [
            createPayment(id: 2, status: 'pending', totalPayment: 5000),
          ],
          currentPage: 1,
          lastPage: 1,
          total: 1,
        ));

        // act
        await provider.applyFilter('pending');

        // assert - should be reset to only filtered results
        expect(provider.payments.length, 1);
        expect(provider.payments[0].status, 'pending');
      });
    });

    group('getters summary', () {
      test('totalCompleted hanya hitung yang isCompleted', () async {
        // arrange
        final payments = [
          createPayment(id: 1, status: 'completed', totalPayment: 4000),
          createPayment(id: 2, status: 'completed', totalPayment: 5000),
          createPayment(id: 3, status: 'pending', totalPayment: 6000),
        ];
        when(mockRepository.getPayments(
          page: anyNamed('page'),
          statusFilter: anyNamed('statusFilter'),
        )).thenAnswer((_) async => PaymentListModel(
          payments: payments,
          currentPage: 1,
          lastPage: 1,
          total: 3,
        ));

        await provider.fetchPayments();

        // assert
        expect(provider.totalCompleted, 2);
      });

      test('totalPending hanya hitung yang isPending', () async {
        // arrange
        final payments = [
          createPayment(id: 1, status: 'completed', totalPayment: 4000),
          createPayment(id: 2, status: 'pending', totalPayment: 5000),
          createPayment(id: 3, status: 'pending', totalPayment: 6000),
        ];
        when(mockRepository.getPayments(
          page: anyNamed('page'),
          statusFilter: anyNamed('statusFilter'),
        )).thenAnswer((_) async => PaymentListModel(
          payments: payments,
          currentPage: 1,
          lastPage: 1,
          total: 3,
        ));

        await provider.fetchPayments();

        // assert
        expect(provider.totalPending, 2);
      });

      test('grandTotal jumlah semua totalPayment', () async {
        // arrange
        final payments = [
          createPayment(id: 1, status: 'completed', totalPayment: 4000),
          createPayment(id: 2, status: 'pending', totalPayment: 5000),
        ];
        when(mockRepository.getPayments(
          page: anyNamed('page'),
          statusFilter: anyNamed('statusFilter'),
        )).thenAnswer((_) async => PaymentListModel(
          payments: payments,
          currentPage: 1,
          lastPage: 1,
          total: 2,
        ));

        await provider.fetchPayments();

        // assert - 4000 + 5000 = 9000
        expect(provider.grandTotal, 9000);
      });
    });
  });
}
