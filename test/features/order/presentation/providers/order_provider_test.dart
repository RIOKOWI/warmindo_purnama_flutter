import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';
import 'package:warmindo_purnama_flutter/features/order/data/models/order_list_model.dart';
import 'package:warmindo_purnama_flutter/features/order/domain/repositories/order_repository.dart';
import 'package:warmindo_purnama_flutter/features/order/presentation/providers/order_provider.dart';

// Mock OrderRepository for testing
class MockOrderRepository implements OrderRepository {
  List<OrderModel> mockOrders = [];
  OrderModel? mockOrderDetail;
  OrderModel? mockCancelledOrder;
  bool shouldFail = false;
  bool getOrdersCalled = false;
  bool getOrderDetailCalled = false;
  bool cancelOrderCalled = false;
  int? lastGetOrdersPage;

  @override
  Future<OrderListModel> getOrders({int page = 1}) async {
    getOrdersCalled = true;
    lastGetOrdersPage = page;
    if (shouldFail) throw Exception('Network error');
    
    // Support pagination: 15 items per page
    const int perPage = 15;
    final int total = mockOrders.length;
    final int lastPage = (total / perPage).ceil();
    
    final int startIndex = (page - 1) * perPage;
    final int endIndex = (startIndex + perPage).clamp(0, total);
    final List<OrderModel> pageOrders = total > 0 
      ? mockOrders.sublist(startIndex, endIndex)
      : [];
    
    return OrderListModel(
      orders: pageOrders,
      currentPage: page,
      lastPage: lastPage,
      total: total,
    );
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    getOrderDetailCalled = true;
    if (shouldFail) throw Exception('Network error');
    if (mockOrderDetail == null) throw Exception('Order not found');
    return mockOrderDetail!;
  }

  @override
  Future<OrderModel> cancelOrder(int orderId) async {
    cancelOrderCalled = true;
    if (shouldFail) throw Exception('Network error');
    if (mockCancelledOrder == null) {
      throw Exception('Failed to cancel');
    }
    return mockCancelledOrder!;
  }
}

void main() {
  group('OrderProvider', () {
    late OrderProvider provider;
    late MockOrderRepository mockRepo;

    setUp(() {
      mockRepo = MockOrderRepository();
      provider = OrderProvider(repository: mockRepo);
    });

    group('fetchOrders', () {
      test('isLoadingList true saat proses, false setelah selesai', () async {
        mockRepo.mockOrders = [];

        expect(provider.isLoadingList, false);

        final future = provider.fetchOrders();
        // onChanged called twice: once when loading starts, once when finishes
        expect(provider.isLoadingList, true);

        await future;
        expect(provider.isLoadingList, false);
      });

      test('orders terisi setelah sukses', () async {
        mockRepo.mockOrders = [
          OrderModel(
            id: 1,
            invoiceNumber: 'INV-001',
            userId: 1,
            orderTypeId: 1,
            subtotal: 1000,
            totalAmount: 1000,
            status: 'pending',
            orderItems: [],
          ),
        ];

        await provider.fetchOrders();

        expect(provider.orders.length, 1);
        expect(provider.orders[0].invoiceNumber, 'INV-001');
      });

      test('refresh: orders direset, bukan append', () async {
        mockRepo.mockOrders = [
          OrderModel(
            id: 1,
            invoiceNumber: 'INV-001',
            userId: 1,
            orderTypeId: 1,
            subtotal: 1000,
            totalAmount: 1000,
            status: 'pending',
            orderItems: [],
          ),
        ];

        await provider.fetchOrders(refresh: true);

        // Add more orders for refresh
        mockRepo.mockOrders = [
          OrderModel(
            id: 1,
            invoiceNumber: 'INV-001',
            userId: 1,
            orderTypeId: 1,
            subtotal: 1000,
            totalAmount: 1000,
            status: 'pending',
            orderItems: [],
          ),
          OrderModel(
            id: 2,
            invoiceNumber: 'INV-002',
            userId: 1,
            orderTypeId: 1,
            subtotal: 2000,
            totalAmount: 2000,
            status: 'pending',
            orderItems: [],
          ),
        ];

        await provider.fetchOrders(refresh: true);

        expect(provider.orders.length, 2);
      });

      test('errorMessage terisi jika gagal', () async {
        mockRepo.shouldFail = true;

        await provider.fetchOrders();

        expect(provider.errorMessage, isNotNull);
      });

      test('isLoadingList false meski gagal (finally)', () async {
        mockRepo.shouldFail = true;

        await provider.fetchOrders();

        expect(provider.isLoadingList, false);
      });
    });

    group('loadMore', () {
      test('tidak memanggil repository jika !hasNextPage', () async {
        await provider.loadMore();

        expect(mockRepo.getOrdersCalled, false);
      });

      test('tidak memanggil repository jika isLoadingList true', () async {
        mockRepo.mockOrders = List.generate(
          15,
          (i) => OrderModel(
            id: i,
            invoiceNumber: 'INV-$i',
            userId: 1,
            orderTypeId: 1,
            subtotal: 1000,
            totalAmount: 1000,
            status: 'pending',
            orderItems: [],
          ),
        );
        await provider.fetchOrders(refresh: true);
        mockRepo.getOrdersCalled = false;

        await provider.loadMore();

        expect(mockRepo.getOrdersCalled, false);
      });

      test('currentPage increment sebelum fetch', () async {
        mockRepo.mockOrders = List.generate(
          30, // Generate 30 orders (2 pages)
          (i) => OrderModel(
            id: i,
            invoiceNumber: 'INV-$i',
            userId: 1,
            orderTypeId: 1,
            subtotal: 1000,
            totalAmount: 1000,
            status: 'pending',
            orderItems: [],
          ),
        );

        // First fetch to set up state
        await provider.fetchOrders(refresh: true);
        expect(mockRepo.lastGetOrdersPage, 1);

        // loadMore should increment page
        await provider.loadMore();
        expect(mockRepo.lastGetOrdersPage, 2);
      });
    });

    group('fetchOrderDetail', () {
      test('isLoadingDetail true saat proses, false setelah selesai', () async {
        mockRepo.mockOrderDetail = OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'pending',
          orderItems: [],
        );

        expect(provider.isLoadingDetail, false);

        final future = provider.fetchOrderDetail(1);
        expect(provider.isLoadingDetail, true);

        await future;
        expect(provider.isLoadingDetail, false);
      });

      test('selectedOrder null dulu sebelum response datang', () async {
        mockRepo.mockOrderDetail = OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'pending',
          orderItems: [],
        );

        final future = provider.fetchOrderDetail(1);
        // selectedOrder should still be null during loading
        expect(provider.selectedOrder, isNull);

        await future;
      });

      test('selectedOrder terisi setelah sukses', () async {
        mockRepo.mockOrderDetail = OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'pending',
          orderItems: [],
        );

        await provider.fetchOrderDetail(1);

        expect(provider.selectedOrder, isNotNull);
        expect(provider.selectedOrder!.invoiceNumber, 'INV-001');
      });

      test('errorMessage terisi jika gagal', () async {
        mockRepo.shouldFail = true;

        await provider.fetchOrderDetail(1);

        expect(provider.errorMessage, isNotNull);
      });
    });

    group('cancelOrder', () {
      test('isCancelling true saat proses, false setelah selesai', () async {
        mockRepo.mockCancelledOrder = OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'cancelled',
          orderItems: [],
        );

        expect(provider.isCancelling, false);

        final future = provider.cancelOrder(1);
        expect(provider.isCancelling, true);

        await future;
        expect(provider.isCancelling, false);
      });

      test('return true jika sukses', () async {
        mockRepo.mockCancelledOrder = OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'cancelled',
          orderItems: [],
        );

        final result = await provider.cancelOrder(1);

        expect(result, true);
      });

      test('return false dan errorMessage terisi jika gagal', () async {
        mockRepo.shouldFail = true;

        final result = await provider.cancelOrder(1);

        expect(result, false);
        expect(provider.errorMessage, isNotNull);
      });

      test('selectedOrder diupdate dengan data cancelled jika id cocok', () async {
        provider.setSelectedOrder(OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'pending',
          orderItems: [],
        ));

        mockRepo.mockCancelledOrder = OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'cancelled',
          orderItems: [],
        );

        await provider.cancelOrder(1);

        expect(provider.selectedOrder!.status, 'cancelled');
      });

      test('order di list _orders juga diupdate (bukan hanya selectedOrder)', () async {
        provider.setOrders([
          OrderModel(
            id: 1,
            invoiceNumber: 'INV-001',
            userId: 1,
            orderTypeId: 1,
            subtotal: 1000,
            totalAmount: 1000,
            status: 'pending',
            orderItems: [],
          ),
        ]);

        mockRepo.mockCancelledOrder = OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'cancelled',
          orderItems: [],
        );

        await provider.cancelOrder(1);

        expect(provider.orders[0].status, 'cancelled');
      });

      test('isCancelling false meski gagal (finally)', () async {
        mockRepo.shouldFail = true;

        await provider.cancelOrder(1);

        expect(provider.isCancelling, false);
      });
    });

    group('clearSelectedOrder', () {
      test('selectedOrder menjadi null', () {
        provider.setSelectedOrder(OrderModel(
          id: 1,
          invoiceNumber: 'INV-001',
          userId: 1,
          orderTypeId: 1,
          subtotal: 1000,
          totalAmount: 1000,
          status: 'pending',
          orderItems: [],
        ));

        provider.clearSelectedOrder();

        expect(provider.selectedOrder, isNull);
      });

      test('errorMessage menjadi null', () {
        provider.setErrorMessage('Some error');

        provider.clearSelectedOrder();

        expect(provider.errorMessage, isNull);
      });
    });
  });
}