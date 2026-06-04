import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/cart/data/models/cart_item_model.dart';

void main() {
  group('CartProduct', () {
    final tJson = {
      'id': 1,
      'name': 'Nasi Goreng',
      'price': 25000,
      'image_url': 'https://example.com/nasi.jpg',
      'stock': 50,
    };

    test('fromJson harus menghasilkan model yang benar', () {
      final result = CartProduct.fromJson(tJson);

      expect(result.id, 1);
      expect(result.name, 'Nasi Goreng');
      expect(result.price, 25000);
      expect(result.imageUrl, 'https://example.com/nasi.jpg');
      expect(result.stock, 50);
    });

    test('fromJson dengan image_url kosong harus return empty string', () {
      final jsonWithoutImage = {...tJson, 'image_url': null};
      final result = CartProduct.fromJson(jsonWithoutImage);

      expect(result.imageUrl, '');
    });

    test('toJson harus mengembalikan map yang benar', () {
      final model = CartProduct.fromJson(tJson);
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Nasi Goreng');
      expect(json['price'], 25000);
      expect(json['image_url'], 'https://example.com/nasi.jpg');
      expect(json['stock'], 50);
    });

    test('equality test dengan Equatable', () {
      final model1 = CartProduct.fromJson(tJson);
      final model2 = CartProduct.fromJson(tJson);

      expect(model1, model2);
    });
  });

  group('CartItem', () {
    final tProductJson = {
      'id': 1,
      'name': 'Nasi Goreng',
      'price': 25000,
      'image_url': 'https://example.com/nasi.jpg',
      'stock': 50,
    };

    final tJson = {
      'cart_item_id': 100,
      'quantity': 2,
      'product': tProductJson,
    };

    test('fromJson harus menghasilkan model yang benar', () {
      final result = CartItem.fromJson(tJson);

      expect(result.cartItemId, 100);
      expect(result.quantity, 2);
      expect(result.product.id, 1);
      expect(result.product.name, 'Nasi Goreng');
      expect(result.product.price, 25000);
    });

    test('toJson harus mengembalikan map yang benar', () {
      final model = CartItem.fromJson(tJson);
      final json = model.toJson();

      expect(json['cart_item_id'], 100);
      expect(json['quantity'], 2);
      expect(json['product'], tProductJson);
    });

    test('subtotal harus product.price * quantity', () {
      final model = CartItem.fromJson(tJson);

      expect(model.subtotal, 50000); // 25000 * 2
    });

    test('subtotal dengan quantity 1', () {
      final jsonWithQty1 = {...tJson, 'quantity': 1};
      final model = CartItem.fromJson(jsonWithQty1);

      expect(model.subtotal, 25000);
    });

    test('equality test dengan Equatable', () {
      final model1 = CartItem.fromJson(tJson);
      final model2 = CartItem.fromJson(tJson);

      expect(model1, model2);
    });
  });

  group('CartResponse', () {
    final tProductJson = {
      'id': 1,
      'name': 'Nasi Goreng',
      'price': 25000,
      'image_url': 'https://example.com/nasi.jpg',
      'stock': 50,
    };

    final tCartItemJson1 = {
      'cart_item_id': 100,
      'quantity': 2,
      'product': tProductJson,
    };

    final tCartItemJson2 = {
      'cart_item_id': 101,
      'quantity': 1,
      'product': {...tProductJson, 'id': 2, 'name': 'Mie Goreng'},
    };

    final tJson = {
      'items': [tCartItemJson1, tCartItemJson2],
      'total_items': 2,
    };

    test('fromJson harus menghasilkan model dengan items yang benar', () {
      final result = CartResponse.fromJson(tJson);

      expect(result.items.length, 2);
      expect(result.items[0].cartItemId, 100);
      expect(result.items[1].cartItemId, 101);
      expect(result.totalItems, 2);
    });

    test('fromJson tanpa total_items harus menggunakan item count', () {
      final jsonWithoutTotal = {'items': [tCartItemJson1, tCartItemJson2]};
      final result = CartResponse.fromJson(jsonWithoutTotal);

      expect(result.totalItems, 2);
    });

    test('fromJson dengan empty items', () {
      final jsonEmpty = {
        'items': [],
        'total_items': 0,
      };
      final result = CartResponse.fromJson(jsonEmpty);

      expect(result.items.isEmpty, true);
      expect(result.totalItems, 0);
    });

    test('equality test dengan Equatable', () {
      final model1 = CartResponse.fromJson(tJson);
      final model2 = CartResponse.fromJson(tJson);

      expect(model1, model2);
    });
  });
}
