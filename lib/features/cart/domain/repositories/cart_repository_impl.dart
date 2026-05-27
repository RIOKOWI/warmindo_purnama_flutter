import 'package:logger/logger.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_repository.dart';

/// Implementation of CartRepository
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._dataSource);

  final CartRemoteDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<List<CartItem>> getCart() async {
    try {
      final response = await _dataSource.getCart();
      _log.i('[CartRepositoryImpl] Cart loaded with ${response.items.length} items');
      return response.items;
    } catch (e, st) {
      _log.e('[CartRepositoryImpl] Failed to get cart', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<CartItem> addItem({
    required int productId,
    required int quantity,
  }) async {
    try {
      final item = await _dataSource.addItem(
        productId: productId,
        quantity: quantity,
      );
      _log.i('[CartRepositoryImpl] Item added: productId=$productId, quantity=$quantity');
      return item;
    } catch (e, st) {
      _log.e('[CartRepositoryImpl] Failed to add item', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<CartItem> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final item = await _dataSource.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      _log.i('[CartRepositoryImpl] Quantity updated: cartItemId=$cartItemId, quantity=$quantity');
      return item;
    } catch (e, st) {
      _log.e('[CartRepositoryImpl] Failed to update quantity', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> removeItem(int cartItemId) async {
    try {
      await _dataSource.removeItem(cartItemId);
      _log.i('[CartRepositoryImpl] Item removed: cartItemId=$cartItemId');
    } catch (e, st) {
      _log.e('[CartRepositoryImpl] Failed to remove item', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _dataSource.clearCart();
      _log.i('[CartRepositoryImpl] Cart cleared');
    } catch (e, st) {
      _log.e('[CartRepositoryImpl] Failed to clear cart', error: e, stackTrace: st);
      rethrow;
    }
  }
}