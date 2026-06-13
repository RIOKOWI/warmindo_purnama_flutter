import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/errors/error_handler.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import '../models/cart_item_model.dart';

/// Remote data source for cart API calls
class CartRemoteDataSource {
  CartRemoteDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// GET /cart - Get entire cart for current user
  Future<CartResponse> getCart() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.cart);

      _log.d('[CartRemoteDataSource] Cart fetched successfully');
      return CartResponse.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e, st) {
      _log.e('[CartRemoteDataSource] Failed to fetch cart', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// POST /cart - Add item to cart
  Future<CartItem> addItem({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.cart,
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );

      _log.d('[CartRemoteDataSource] Item added: $productId x$quantity');
      return CartItem.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e, st) {
      _log.e('[CartRemoteDataSource] Failed to add item', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// PATCH /cart/{cart_item_id} - Update quantity
  Future<CartItem> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        ApiConstants.cartItem(cartItemId),
        data: {'quantity': quantity},
      );

      _log.d('[CartRemoteDataSource] Quantity updated: $cartItemId -> $quantity');
      return CartItem.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e, st) {
      _log.e('[CartRemoteDataSource] Failed to update quantity', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// DELETE /cart/{cart_item_id} - Remove item from cart
  Future<void> removeItem(int cartItemId) async {
    try {
      await _dioClient.dio.delete(ApiConstants.cartItem(cartItemId));

      _log.d('[CartRemoteDataSource] Item removed: $cartItemId');
    } catch (e, st) {
      _log.e('[CartRemoteDataSource] Failed to remove item', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// DELETE /cart - Clear entire cart
  Future<void> clearCart() async {
    try {
      await _dioClient.dio.delete(ApiConstants.cart);

      _log.d('[CartRemoteDataSource] Cart cleared');
    } catch (e, st) {
      _log.e('[CartRemoteDataSource] Failed to clear cart', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }
}