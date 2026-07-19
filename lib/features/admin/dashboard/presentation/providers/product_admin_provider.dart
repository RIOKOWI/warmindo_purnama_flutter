import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import '../../domain/repositories/product_admin_repository.dart';
import '../../data/models/product_request_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';

/// Provider untuk admin product management
class ProductAdminProvider extends ChangeNotifier {
  ProductAdminProvider({required ProductAdminRepository repository})
      : _repository = repository;

  final ProductAdminRepository _repository;
  final Logger _log = Logger();

  // State
  bool _isSubmitting = false;
  bool _isDeleting = false;
  String? _errorMessage;

  // Getters
  bool get isSubmitting => _isSubmitting;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  /// Create new product
  Future<ProductModel?> createProduct(ProductRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[ProductAdminProvider] Creating product: ${request.name}');
      final result = await _repository.createProduct(request);
      _log.i('[ProductAdminProvider] Product created successfully: ${result.id}');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[ProductAdminProvider] Failed to create product',
          error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update existing product
  Future<ProductModel?> updateProduct(int id, ProductRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[ProductAdminProvider] Updating product: $id');
      final result = await _repository.updateProduct(id, request);
      _log.i('[ProductAdminProvider] Product updated successfully: ${result.id}');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[ProductAdminProvider] Failed to update product',
          error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Delete product
  Future<bool> deleteProduct(int id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[ProductAdminProvider] Deleting product: $id');
      await _repository.deleteProduct(id);
      _log.i('[ProductAdminProvider] Product deleted successfully: $id');
      return true;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[ProductAdminProvider] Failed to delete product',
          error: e, stackTrace: st);
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}