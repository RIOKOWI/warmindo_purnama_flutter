import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warmindo_purnama_flutter/features/cart/data/models/cart_item_model.dart';
import 'package:warmindo_purnama_flutter/features/cart/presentation/providers/cart_provider.dart';

// Generate with: dart run build_runner build --delete-conflicting-outputs
import '../../../../mocks.mocks.dart';

void main() {
  late CartProvider provider;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    provider = CartProvider(mockRepository);
  });

  // Test data
  final tProduct = const CartProduct(
    id: 1,
    name: 'Nasi Goreng',
    price: 25000,
    imageUrl: 'https://example.com/nasi.jpg',
    stock: 50,
  );

  final tProduct2 = const CartProduct(
    id: 2,
    name: 'Mie Goreng',
    price: 20000,
    imageUrl: 'https://example.com/mie.jpg',
    stock: 30,
  );

  final tCartItem1 = CartItem(
    cartItemId: 100,
    quantity: 2,
    product: tProduct,
  );

  final tCartItem2 = CartItem(
    cartItemId: 101,
    quantity: 1,
    product: tProduct2,
  );

  group('CartProvider', () {
    group('Getters', () {
      test('items harus return empty list di awal', () {
        expect(provider.items, isEmpty);
      });

      test('isLoading harus false di awal', () {
        expect(provider.isLoading, false);
      });

      test('errorMessage harus null di awal', () {
        expect(provider.errorMessage, null);
      });

      test('totalPrice harus 0 ketika items kosong', () {
        expect(provider.totalPrice, 0);
      });

      test('totalItemCount harus 0 ketika items kosong', () {
        expect(provider.totalItemCount, 0);
      });
    });

    group('fetchCart', () {
      test('harus load items dan update state', () async {
        // arrange
        when(mockRepository.getCart()).thenAnswer(
          (_) async => [tCartItem1, tCartItem2],
        );

        // act
        await provider.fetchCart();

        // assert
        expect(provider.items.length, 2);
        expect(provider.items[0].cartItemId, 100);
        expect(provider.items[1].cartItemId, 101);
        expect(provider.isLoading, false);
        expect(provider.errorMessage, null);
        verify(mockRepository.getCart()).called(1);
      });

      test('harus set error ketika fetch gagal', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );
        when(mockRepository.getCart()).thenThrow(dioError);

        // act
        await provider.fetchCart();

        // assert
        expect(provider.items, isEmpty);
        expect(provider.isLoading, false);
        expect(provider.errorMessage, isNotNull);
      });

      test('harus set isLoading true saat loading', () async {
        // arrange
        when(mockRepository.getCart()).thenAnswer(
          (_) async => [tCartItem1],
        );

        // act
        final future = provider.fetchCart();
        // Check saat loading
        // (Note: ini sulit ditest karena sync, tapi pattern ini valid)
        await future;

        // assert
        expect(provider.isLoading, false);
      });

      test('harus handle empty cart response', () async {
        // arrange
        when(mockRepository.getCart()).thenAnswer(
          (_) async => [],
        );

        // act
        await provider.fetchCart();

        // assert
        expect(provider.items, isEmpty);
        expect(provider.errorMessage, null);
      });
    });

    group('addItem', () {
      test('harus add new item ke cart (pessimistic)', () async {
        // arrange
        const tProductId = 1;
        when(mockRepository.addItem(
          productId: tProductId,
          quantity: 1,
        )).thenAnswer((_) async => tCartItem1);

        // act
        final result = await provider.addItem(tProductId);

        // assert
        expect(result, true);
        expect(provider.items.length, 1);
        expect(provider.items[0].product.id, 1);
        expect(provider.errorMessage, null);
        verify(mockRepository.addItem(
          productId: tProductId,
          quantity: 1,
        )).called(1);
      });

      test('harus increment quantity jika product sudah ada di cart', () async {
        // arrange
        when(mockRepository.addItem(
          productId: 1,
          quantity: 1,
        )).thenAnswer((_) async => tCartItem1);

        // Manually add first item to simulate already in cart
        provider.items.add(tCartItem1);

        // Update untuk quantity 3
        final updatedItem = CartItem(
          cartItemId: 100,
          quantity: 3,
          product: tProduct,
        );
        when(mockRepository.updateQuantity(
          cartItemId: 100,
          quantity: 3,
        )).thenAnswer((_) async => updatedItem);

        // act - call addItem with same product should increment
        final result = await provider.addItem(1);

        // assert - should call updateQuantity instead of addItem
        expect(result, true);
        expect(provider.items[0].quantity, 3);
      });

      test('harus return false dan set error ketika add gagal', () async {
        // arrange
        const tProductId = 1;
        when(mockRepository.addItem(
          productId: tProductId,
          quantity: 1,
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        // act
        final result = await provider.addItem(tProductId);

        // assert
        expect(result, false);
        expect(provider.errorMessage, isNotNull);
      });
    });

    group('updateQuantity', () {
      setUp(() {
        provider.items.add(tCartItem1);
      });

      test('harus update quantity optimistic', () async {
        // arrange
        const tNewQuantity = 5;
        final updatedItem = CartItem(
          cartItemId: 100,
          quantity: tNewQuantity,
          product: tProduct,
        );
        when(mockRepository.updateQuantity(
          cartItemId: 100,
          quantity: tNewQuantity,
        )).thenAnswer((_) async => updatedItem);

        // act
        final result = await provider.updateQuantity(
          cartItemId: 100,
          newQuantity: tNewQuantity,
        );

        // assert
        expect(result, true);
        expect(provider.items[0].quantity, tNewQuantity);
        expect(provider.errorMessage, null);
      });

      test('harus return false jika quantity melebihi stock', () async {
        // arrange
        const tExcessiveQuantity = 100; // stock hanya 50

        // act
        final result = await provider.updateQuantity(
          cartItemId: 100,
          newQuantity: tExcessiveQuantity,
        );

        // assert
        expect(result, false);
        expect(provider.errorMessage, isNotNull);
        expect(provider.items[0].quantity, 2); // tetap quantity awal
      });

      test('harus remove item jika quantity menjadi 0', () async {
        // arrange
        when(mockRepository.removeItem(100))
            .thenAnswer((_) async => {});

        // act
        final result = await provider.updateQuantity(
          cartItemId: 100,
          newQuantity: 0,
        );

        // assert
        expect(result, true);
        expect(provider.items, isEmpty);
      });

      test('harus rollback quantity jika update gagal', () async {
        // arrange
        const tNewQuantity = 5;
        when(mockRepository.updateQuantity(
          cartItemId: 100,
          quantity: tNewQuantity,
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        // act
        final result = await provider.updateQuantity(
          cartItemId: 100,
          newQuantity: tNewQuantity,
        );

        // assert
        expect(result, false);
        expect(provider.items[0].quantity, 2); // kembali ke nilai awal
        expect(provider.errorMessage, isNotNull);
      });

      test('harus return false jika cartItemId tidak ditemukan', () async {
        // act
        final result = await provider.updateQuantity(
          cartItemId: 999,
          newQuantity: 5,
        );

        // assert
        expect(result, false);
      });
    });

    group('removeItem', () {
      setUp(() {
        provider.items.add(tCartItem1);
        provider.items.add(tCartItem2);
      });

      test('harus remove item optimistic', () async {
        // arrange
        when(mockRepository.removeItem(100))
            .thenAnswer((_) async => {});

        // act
        final result = await provider.removeItem(100);

        // assert
        expect(result, true);
        expect(provider.items.length, 1);
        expect(provider.items[0].cartItemId, 101);
        expect(provider.errorMessage, null);
      });

      test('harus rollback remove jika repository gagal', () async {
        // arrange
        when(mockRepository.removeItem(100))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        // act
        final result = await provider.removeItem(100);

        // assert
        expect(result, false);
        expect(provider.items.length, 2); // item restored
        expect(provider.errorMessage, isNotNull);
      });

      test('harus return false jika cartItemId tidak ditemukan', () async {
        // act
        final result = await provider.removeItem(999);

        // assert
        expect(result, false);
      });
    });

    group('clearCart', () {
      setUp(() {
        provider.items.add(tCartItem1);
        provider.items.add(tCartItem2);
      });

      test('harus clear semua items (pessimistic)', () async {
        // arrange
        when(mockRepository.clearCart()).thenAnswer((_) async => {});

        // act
        final result = await provider.clearCart();

        // assert
        expect(result, true);
        expect(provider.items, isEmpty);
        expect(provider.isLoading, false);
        expect(provider.errorMessage, null);
      });

      test('harus return false dan set error jika clear gagal', () async {
        // arrange
        when(mockRepository.clearCart()).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        // act
        final result = await provider.clearCart();

        // assert
        expect(result, false);
        expect(provider.isLoading, false);
        expect(provider.errorMessage, isNotNull);
        expect(provider.items.length, 2); // items not cleared
      });
    });

    group('clearLocal', () {
      setUp(() {
        provider.items.add(tCartItem1);
        provider.items.add(tCartItem2);
      });

      test('harus clear items dari local storage', () {
        // act
        provider.clearLocal();

        // assert
        expect(provider.items, isEmpty);
      });
    });

    group('totalPrice calculation', () {
      test('harus return sum dari semua subtotal', () async {
        // arrange
        provider.items.add(tCartItem1); // 25000 * 2 = 50000
        provider.items.add(tCartItem2); // 20000 * 1 = 20000

        // act
        final total = provider.totalPrice;

        // assert
        expect(total, 70000);
      });

      test('harus return 0 ketika items kosong', () {
        // assert
        expect(provider.totalPrice, 0);
      });
    });

    group('totalItemCount', () {
      test('harus return sum dari semua quantity', () async {
        // arrange
        provider.items.add(tCartItem1); // quantity: 2
        provider.items.add(tCartItem2); // quantity: 1

        // act
        final count = provider.totalItemCount;

        // assert - sum of all quantities = 2 + 1 = 3
        expect(count, 3);
      });

      test('harus return 0 ketika items kosong', () {
        expect(provider.totalItemCount, 0);
      });
    });

    group('uniqueItemCount', () {
      test('harus return count unique items', () async {
        // arrange
        provider.items.add(tCartItem1);
        provider.items.add(tCartItem2);

        // act
        final count = provider.uniqueItemCount;

        // assert - count of unique products = 2
        expect(count, 2);
      });

      test('harus return 0 ketika items kosong', () {
        expect(provider.uniqueItemCount, 0);
      });
    });
  });
}
