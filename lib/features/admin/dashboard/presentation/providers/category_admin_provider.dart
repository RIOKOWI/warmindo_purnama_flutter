import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import '../../domain/repositories/category_admin_repository.dart';
import '../../data/models/category_request_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';

/// Provider untuk admin category management
class CategoryAdminProvider extends ChangeNotifier {
  CategoryAdminProvider({required CategoryAdminRepository repository})
      : _repository = repository;

  final CategoryAdminRepository _repository;
  final Logger _log = Logger();

  // State
  bool _isSubmitting = false;
  bool _isDeleting = false;
  String? _errorMessage;

  // Getters
  bool get isSubmitting => _isSubmitting;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  /// Create new category
  Future<CategoryModel?> createCategory(CategoryRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[CategoryAdminProvider] Creating category: ${request.name}');
      final result = await _repository.createCategory(request);
      _log.i('[CategoryAdminProvider] Category created successfully: ${result.id}');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[CategoryAdminProvider] Failed to create category',
          error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update existing category
  Future<CategoryModel?> updateCategory(int id, CategoryRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[CategoryAdminProvider] Updating category: $id');
      final result = await _repository.updateCategory(id, request);
      _log.i('[CategoryAdminProvider] Category updated successfully: ${result.id}');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[CategoryAdminProvider] Failed to update category',
          error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Delete category
  Future<bool> deleteCategory(int id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[CategoryAdminProvider] Deleting category: $id');
      await _repository.deleteCategory(id);
      _log.i('[CategoryAdminProvider] Category deleted successfully: $id');
      return true;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[CategoryAdminProvider] Failed to delete category',
          error: e, stackTrace: st);
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}