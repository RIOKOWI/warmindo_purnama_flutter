import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warmindo_purnama_flutter/features/cart/data/models/cart_item_model.dart';
import 'package:warmindo_purnama_flutter/features/cart/domain/repositories/cart_repository_impl.dart';

// Generate with: dart run build_runner build --delete-conflicting-outputs
import '../../../../mocks.mocks.dart';

void main() {
  late CartRepositoryImpl repository;
  late MockCartRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockCartRemoteDataSource();
    repository = CartRepositoryImpl(mockDataSource);
  });

  group('CartRepositoryImpl', () {
    // Test data
    final tProduct = const CartProduct(
      id: 1,
      name: 'Nasi Goreng',
      price: 25000,
      imageUrl: 'https://example.com/nasi.jpg',
      stock: 50,
    );

    final tCartItem = CartItem(
      cartItemId: 100,
      quantity: 2,
      product: tProduct,
    );

    final tCartResponse = CartResponse(
      items: [tCartItem],
      totalItems: 1,
    );

    group('getCart', () {
      test('harus return list CartItem ketika datasource berhasil', () async {
        // arrange
        when(mockDataSource.getCart()).thenAnswer(
          (_) async => tCartResponse,
        );

        // act
        final result = await repository.getCart();

        // assert
        expect(result, [tCartItem]);
        expect(result.length, 1);
        expect(result[0].cartItemId, 100);
        verify(mockDataSource.getCart()).called(1);
      });

      test('harus throw exception ketika datasource gagal', () async {
        // arrange
        when(mockDataSource.getCart()).thenThrow(Exception('Network error'));

        // act & assert
        expect(
          () => repository.getCart(),
          throwsException,
        );
        verify(mockDataSource.getCart()).called(1);
      });

      test('harus return empty list ketika cart kosong', () async {
        // arrange
        final emptyResponse = const CartResponse(items: [], totalItems: 0);
        when(mockDataSource.getCart()).thenAnswer(
          (_) async => emptyResponse,
        );

        // act
        final result = await repository.getCart();

        // assert
        expect(result, isEmpty);
        expect(result.length, 0);
      });
    });

    group('addItem', () {
      const tProductId = 1;
      const tQuantity = 2;

      test('harus return CartItem ketika berhasil ditambah', () async {
        // arrange
        when(mockDataSource.addItem(
          productId: tProductId,
          quantity: tQuantity,
        )).thenAnswer((_) async => tCartItem);

        // act
        final result = await repository.addItem(
          productId: tProductId,
          quantity: tQuantity,
        );

        // assert
        expect(result, tCartItem);
        expect(result.quantity, tQuantity);
        verify(mockDataSource.addItem(
          productId: tProductId,
          quantity: tQuantity,
        )).called(1);
      });

      test('harus throw exception ketika datasource gagal', () async {
        // arrange
        when(mockDataSource.addItem(
          productId: tProductId,
          quantity: tQuantity,
        )).thenThrow(Exception('Failed to add item'));

        // act & assert
        expect(
          () => repository.addItem(
            productId: tProductId,
            quantity: tQuantity,
          ),
          throwsException,
        );
      });
    });

    group('updateQuantity', () {
      const tCartItemId = 100;
      const tNewQuantity = 5;

      test('harus return updated CartItem', () async {
        // arrange
        final updatedItem = CartItem(
          cartItemId: tCartItemId,
          quantity: tNewQuantity,
          product: tProduct,
        );
        when(mockDataSource.updateQuantity(
          cartItemId: tCartItemId,
          quantity: tNewQuantity,
        )).thenAnswer((_) async => updatedItem);

        // act
        final result = await repository.updateQuantity(
          cartItemId: tCartItemId,
          quantity: tNewQuantity,
        );

        // assert
        expect(result, updatedItem);
        expect(result.quantity, tNewQuantity);
        verify(mockDataSource.updateQuantity(
          cartItemId: tCartItemId,
          quantity: tNewQuantity,
        )).called(1);
      });

      test('harus throw exception ketika datasource gagal', () async {
        // arrange
        when(mockDataSource.updateQuantity(
          cartItemId: tCartItemId,
          quantity: tNewQuantity,
        )).thenThrow(Exception('Failed to update'));

        // act & assert
        expect(
          () => repository.updateQuantity(
            cartItemId: tCartItemId,
            quantity: tNewQuantity,
          ),
          throwsException,
        );
      });
    });

    group('removeItem', () {
      const tCartItemId = 100;

      test('harus berhasil menghapus item', () async {
        // arrange
        when(mockDataSource.removeItem(tCartItemId))
            .thenAnswer((_) async => {});

        // act
        await repository.removeItem(tCartItemId);

        // assert
        verify(mockDataSource.removeItem(tCartItemId)).called(1);
      });

      test('harus throw exception ketika datasource gagal', () async {
        // arrange
        when(mockDataSource.removeItem(tCartItemId))
            .thenThrow(Exception('Failed to remove'));

        // act & assert
        expect(
          () => repository.removeItem(tCartItemId),
          throwsException,
        );
      });
    });

    group('clearCart', () {
      test('harus berhasil mengosongkan cart', () async {
        // arrange
        when(mockDataSource.clearCart()).thenAnswer((_) async => {});

        // act
        await repository.clearCart();

        // assert
        verify(mockDataSource.clearCart()).called(1);
      });

      test('harus throw exception ketika datasource gagal', () async {
        // arrange
        when(mockDataSource.clearCart())
            .thenThrow(Exception('Failed to clear'));

        // act & assert
        expect(
          () => repository.clearCart(),
          throwsException,
        );
      });
    });
  });
}
