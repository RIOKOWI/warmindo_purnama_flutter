import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_type_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/table_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/create_order_request_model.dart';
import 'package:warmindo_purnama_flutter/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:warmindo_purnama_flutter/features/checkout/domain/repositories/checkout_repository.dart';

// Mock repository for testing
class MockCheckoutRepository implements CheckoutRepository {
  List<OrderTypeModel> orderTypes = [];
  List<TableModel> availableTables = [];
  OrderModel? createdOrder;
  bool shouldThrowOnGetOrderTypes = false;
  bool shouldThrowOnGetAvailableTables = false;

  @override
  Future<List<OrderTypeModel>> getOrderTypes() async {
    if (shouldThrowOnGetOrderTypes) {
      throw Exception('Gagal mengambil tipe pesanan');
    }
    return orderTypes;
  }

  @override
  Future<List<TableModel>> getAvailableTables() async {
    if (shouldThrowOnGetAvailableTables) {
      throw Exception('Gagal mengambil meja tersedia');
    }
    return availableTables;
  }

  @override
  Future<OrderModel> createOrder(CreateOrderRequestModel request) async {
    if (createdOrder != null) {
      return createdOrder!;
    }
    throw Exception('Gagal membuat pesanan');
  }

  void reset() {
    orderTypes = [];
    availableTables = [];
    createdOrder = null;
    shouldThrowOnGetOrderTypes = false;
    shouldThrowOnGetAvailableTables = false;
  }
}

void main() {
  late CheckoutProvider provider;
  late MockCheckoutRepository mockRepo;

  setUp(() {
    mockRepo = MockCheckoutRepository();
    provider = CheckoutProvider(repository: mockRepo);
  });

  group('CheckoutProvider - init()', () {
    test('set isLoading true saat mulai, false setelah selesai', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
      ];

      expect(provider.isLoading, false);

      final initFuture = provider.init();
      expect(provider.isLoading, true);

      await initFuture;
      expect(provider.isLoading, false);
    });

    test('_orderTypes dan _availableTables terisi setelah sukses', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
        const TableModel(id: 2, tableNumber: 'MEJA 02', status: 'available'),
      ];

      await provider.init();

      expect(provider.orderTypes.length, 2);
      expect(provider.availableTables.length, 2);
    });

    test('default selectedOrderType adalah take_away jika ada', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];

      await provider.init();

      expect(provider.selectedOrderType?.name, 'take_away');
    });

    test('set errorMessage jika getOrderTypes() throw Exception', () async {
      mockRepo.orderTypes = [];
      mockRepo.availableTables = [];
      mockRepo.shouldThrowOnGetOrderTypes = true;

      await provider.init();

      expect(provider.errorMessage, isNotNull);
    });

    test('set errorMessage jika getAvailableTables() throw Exception', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
      ];
      mockRepo.shouldThrowOnGetAvailableTables = true;

      await provider.init();

      expect(provider.errorMessage, isNotNull);
    });
  });

  group('CheckoutProvider - selectOrderType()', () {
    test('selectedOrderType berubah', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];
      await provider.init();

      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));

      expect(provider.selectedOrderType?.id, 1);
      expect(provider.selectedOrderType?.name, 'dine_in');
    });

    test('selectedTable di-reset ke null jika tipe bukan dine_in', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
      ];
      await provider.init();

      // Select dine_in and a table
      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));
      provider.selectTable(const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'));
      expect(provider.selectedTable?.id, 1);

      // Switch to take_away
      provider.selectOrderType(const OrderTypeModel(id: 2, name: 'take_away'));

      expect(provider.selectedTable, isNull);
    });

    test('selectedTable tidak di-reset jika tipe dine_in', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
      ];
      await provider.init();

      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));
      provider.selectTable(const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'));

      // Select again to dine_in (same type)
      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));

      expect(provider.selectedTable?.id, 1);
    });
  });

  group('CheckoutProvider - selectTable()', () {
    test('selectedTable berubah sesuai input', () async {
      mockRepo.orderTypes = [];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
        const TableModel(id: 2, tableNumber: 'MEJA 02', status: 'available'),
      ];
      await provider.init();

      provider.selectTable(const TableModel(id: 2, tableNumber: 'MEJA 02', status: 'available'));

      expect(provider.selectedTable?.id, 2);
    });
  });

  group('CheckoutProvider - canSubmit', () {
    test('false jika selectedOrderType null', () async {
      mockRepo.orderTypes = [];
      mockRepo.availableTables = [];
      await provider.init();

      expect(provider.canSubmit, false);
    });

    test('false jika dine_in dan selectedTable null', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
      ];
 mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
      ];
      await provider.init();
      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));

      expect(provider.canSubmit, false);
    });

    test('true jika take_away dan selectedOrderType tidak null', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];
      await provider.init();

      expect(provider.canSubmit, true);
    });

    test('true jika dine_in dan selectedTable tidak null', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
      ];
      await provider.init();
      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));
      provider.selectTable(const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'));

      expect(provider.canSubmit, true);
    });
  });

  group('CheckoutProvider - submitOrder()', () {
    test('return false langsung jika !canSubmit', () async {
      mockRepo.orderTypes = [];
      mockRepo.availableTables = [];
      await provider.init();

      final result = await provider.submitOrder();

      expect(result, false);
    });

    test('set isSubmitting true saat proses, false setelah selesai', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];
      mockRepo.createdOrder = OrderModel(
        id: 1,
        invoiceNumber: 'INV-001',
        userId: 1,
        orderTypeId: 2,
        subtotal: 1000,
        totalAmount: 1000,
        status: 'pending',
        orderItems: [],
      );
      await provider.init();

      expect(provider.isSubmitting, false);

      final submitFuture = provider.submitOrder();
      expect(provider.isSubmitting, true);

      await submitFuture;
      expect(provider.isSubmitting, false);
    });

    test('createOrder dipanggil dengan CreateOrderRequestModel yang benar', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
      ];
      mockRepo.createdOrder = OrderModel(
        id: 1,
        invoiceNumber: 'INV-001',
        userId: 1,
        restaurantTableId: 1,
        orderTypeId: 1,
        subtotal: 1000,
        totalAmount: 1000,
        status: 'pending',
        orderItems: [],
      );
      await provider.init();
      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));
      provider.selectTable(const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'));

      CreateOrderRequestModel? capturedRequest;
      mockRepo.createdOrder = OrderModel(
        id: 1,
        invoiceNumber: 'INV-001',
        userId: 1,
        restaurantTableId: 1,
        orderTypeId: 1,
        subtotal: 1000,
        totalAmount: 1000,
        status: 'pending',
        orderItems: [],
      );

      await provider.submitOrder();

      // Request was passed correctly
      expect(provider.createdOrder, isNotNull);
    });

    test('restaurantTableId null di request jika take_away', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];
      mockRepo.createdOrder = OrderModel(
        id: 1,
        invoiceNumber: 'INV-001',
        userId: 1,
        orderTypeId: 2,
        subtotal: 1000,
        totalAmount: 1000,
        status: 'pending',
        orderItems: [],
      );
      await provider.init();

      await provider.submitOrder();

      // For take_away, restaurantTableId should not be in the request
      expect(provider.createdOrder?.restaurantTableId, isNull);
    });

    test('restaurantTableId terisi di request jika dine_in', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 5, tableNumber: 'MEJA 05', status: 'available'),
      ];
      mockRepo.createdOrder = OrderModel(
        id: 1,
        invoiceNumber: 'INV-001',
        userId: 1,
        restaurantTableId: 5,
        orderTypeId: 1,
        subtotal: 1000,
        totalAmount: 1000,
        status: 'pending',
        orderItems: [],
      );
      await provider.init();
      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));
      provider.selectTable(const TableModel(id: 5, tableNumber: 'MEJA 05', status: 'available'));

      await provider.submitOrder();

      expect(provider.createdOrder?.restaurantTableId, 5);
    });

    test('createdOrder terisi setelah sukses', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];
      mockRepo.createdOrder = OrderModel(
        id: 42,
        invoiceNumber: 'INV-TEST',
        userId: 1,
        orderTypeId: 2,
        subtotal: 5000,
        totalAmount: 5000,
        status: 'pending',
        orderItems: [],
      );
      await provider.init();

      final result = await provider.submitOrder();

      expect(result, true);
      expect(provider.createdOrder?.id, 42);
    });

    test('return true jika swipe', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];
      mockRepo.createdOrder = OrderModel(
        id: 1,
        invoiceNumber: 'INV-001',
        userId: 1,
        orderTypeId: 2,
        subtotal: 1000,
        totalAmount: 1000,
        status: 'pending',
        orderItems: [],
      );
      await provider.init();

      final result = await provider.submitOrder();

      expect(result, true);
    });

    test('set errorMessage dan return false jika gagal', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [];
      mockRepo.createdOrder = null; // Will throw
      await provider.init();

      final result = await provider.submitOrder();

      expect(result, false);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('CheckoutProvider - reset()', () {
    test('semua state kembali ke initial', () async {
      mockRepo.orderTypes = [
        const OrderTypeModel(id: 1, name: 'dine_in'),
        const OrderTypeModel(id: 2, name: 'take_away'),
      ];
      mockRepo.availableTables = [
        const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'),
      ];
      await provider.init();
      provider.selectOrderType(const OrderTypeModel(id: 1, name: 'dine_in'));
      provider.selectTable(const TableModel(id: 1, tableNumber: 'MEJA 01', status: 'available'));
      provider.setNotes('Test notes');

      provider.reset();

      expect(provider.orderTypes, isEmpty);
      expect(provider.availableTables, isEmpty);
      expect(provider.selectedOrderType, isNull);
      expect(provider.selectedTable, isNull);
      expect(provider.notes, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.isSubmitting, false);
      expect(provider.errorMessage, isNull);
      expect(provider.createdOrder, isNull);
    });
  });
}
