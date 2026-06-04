import '../../data/models/cart_item_model.dart';

/// Abstract repository interface for cart operations
abstract class CartRepository {
  /// Get cart items for current user
  Future<List<CartItem>> getCart();

  /// Add item to cart
  Future<CartItem> addItem({
    required int productId,
    required int quantity,
  });

  /// Update cart item quantity
  Future<CartItem> updateQuantity({
    required int cartItemId,
    required int quantity,
  });

  /// Remove item from cart
  Future<void> removeItem(int cartItemId);

  /// Clear all items from cart
  Future<void> clearCart();
}