import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import '../../data/models/cart_item_model.dart';
import '../../domain/repositories/cart_repository.dart';

/// Cart provider for state management with optimistic/pessimistic update patterns
///
/// - **Optimistic update** (UI first, sync later): update quantity, remove item
/// - **Pessimistic update** (wait for server): add item, clear cart
class CartProvider extends ChangeNotifier {
  CartProvider(this._repository);

  final CartRepository _repository;
  final Logger _log = Logger();

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Total price of all items in cart
  int get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Number of unique items in cart
  int get uniqueItemCount => _items.length;

  /// Total quantity of all items in cart (for badge display)
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // ─── Fetch ──────────────────────────────────────────────

  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getCart();
      _log.i('[CartProvider] Cart fetched: ${_items.length} items');
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.w('[CartProvider] Failed to fetch cart', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Add Item ────────────────────────────────────────────

  /// Pessimistic: wait for server response, then update UI
  Future<bool> addItem(int productId) async {
    _errorMessage = null;

    try {
      // Check if product already in cart
      final existingIndex = _items.indexWhere(
        (item) => item.product.id == productId,
      );

      if (existingIndex != -1) {
        // Already in cart -> increment quantity
        return await updateQuantity(
          cartItemId: _items[existingIndex].cartItemId,
          newQuantity: _items[existingIndex].quantity + 1,
        );
      }

      // Not in cart -> add new item (pessimistic)
      _isLoading = true;
      notifyListeners();

      final newItem = await _repository.addItem(
        productId: productId,
        quantity: 1,
      );
      _items.add(newItem);
      _log.i('[CartProvider] Item added: productId=$productId');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.w('[CartProvider] Failed to add item', error: e, stackTrace: st);
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
      return false;
    }
  }

  // ─── Update Quantity ─────────────────────────────────────

  /// Optimistic: update UI first, sync to server in background
  Future<bool> updateQuantity({
    required int cartItemId,
    required int newQuantity,
  }) async {
    final index = _items.indexWhere((i) => i.cartItemId == cartItemId);
    if (index == -1) return false;

    // Check stock limit
    if (newQuantity > _items[index].product.stock) {
      _errorMessage = 'Jumlah melebihi stok tersedia';
      _log.w('[CartProvider] Stock limit exceeded for cartItemId=$cartItemId');
      notifyListeners();
      return false;
    }

    // If quantity becomes 0 -> remove item
    if (newQuantity <= 0) {
      return await removeItem(cartItemId);
    }

    // Store old value for rollback
    final oldQuantity = _items[index].quantity;

    // Optimistic update: update UI now
    _items[index] = CartItem(
      cartItemId: _items[index].cartItemId,
      quantity: newQuantity,
      product: _items[index].product,
    );
    _log.d('[CartProvider] Optimistic update: cartItemId=$cartItemId quantity=$newQuantity');
    notifyListeners();

    try {
      // Sync to server
      await _repository.updateQuantity(
        cartItemId: cartItemId,
        quantity: newQuantity,
      );
      _log.d('[CartProvider] Synced to server: cartItemId=$cartItemId');
      return true;
    } catch (e, st) {
      // Rollback on failure
      _items[index] = CartItem(
        cartItemId: _items[index].cartItemId,
        quantity: oldQuantity,
        product: _items[index].product,
      );
      _errorMessage = 'Gagal mengubah jumlah';
      _log.w('[CartProvider] Rollback: cartItemId=$cartItemId', error: e, stackTrace: st);
      notifyListeners();
      return false;
    }
  }

  // ─── Remove Item ─────────────────────────────────────────

  /// Optimistic: remove from list first, rollback if server fails
  Future<bool> removeItem(int cartItemId) async {
    final index = _items.indexWhere((i) => i.cartItemId == cartItemId);
    if (index == -1) return false;

    // Store for rollback
    final removedItem = _items[index];

    // Optimistic remove
    _items.removeAt(index);
    _log.d('[CartProvider] Optimistic remove: cartItemId=$cartItemId');
    notifyListeners();

    try {
      await _repository.removeItem(cartItemId);
      _log.i('[CartProvider] Item removed: cartItemId=$cartItemId');
      return true;
    } catch (e, st) {
      // Rollback: restore item
      _items.insert(index, removedItem);
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.w('[CartProvider] Rollback: failed to remove cartItemId=$cartItemId', error: e, stackTrace: st);
      notifyListeners();
      return false;
    }
  }

  // ─── Clear Cart ───────────────────────────────────────────

  /// Pessimistic: wait for server, then clear local state
  Future<bool> clearCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.clearCart();
      _items = [];
      _log.i('[CartProvider] Cart cleared');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.w('[CartProvider] Failed to clear cart', error: e, stackTrace: st);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear local cart state only (for after successful order)
  void clearLocal() {
    _items = [];
    _log.i('[CartProvider] Local cart cleared');
    notifyListeners();
  }
}
