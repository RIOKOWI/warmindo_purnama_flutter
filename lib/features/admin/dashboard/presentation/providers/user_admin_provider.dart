import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import '../../domain/repositories/user_admin_repository.dart';
import '../../data/models/user_admin_model.dart';
import '../../data/models/user_request_model.dart';

/// Provider untuk admin user management
class UserAdminProvider extends ChangeNotifier {
  UserAdminProvider({required UserAdminRepository repository})
      : _repository = repository;

  final UserAdminRepository _repository;
  final Logger _log = Logger();

  // State
  List<UserAdminModel> _users = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSubmitting = false;
  bool _isProcessing = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = false;

  // Getters
  List<UserAdminModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSubmitting => _isSubmitting;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;

  // Summary getters
  int get totalAdmin =>
      _users.where((u) => u.role == 'admin').length;
  int get totalKasir =>
      _users.where((u) => u.role == 'kasir').length;
  int get totalCustomer =>
      _users.where((u) => u.role == 'customer').length;
  int get totalDeleted =>
      _users.where((u) => u.isDeleted).length;

  /// Fetch users (initial load or refresh)
  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _users = [];
    }

    _isLoading = _users.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[UserAdminProvider] Fetch users page: $_currentPage');
      final result = await _repository.getUsers(page: _currentPage);

      if (refresh) {
        _users = result.users;
      } else {
        _users.addAll(result.users);
      }

      _hasNextPage = result.hasNextPage;
      _log.i('[UserAdminProvider] Users loaded: ${_users.length}, hasNextPage: $_hasNextPage');
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[UserAdminProvider] Failed to fetch users',
          error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more users for pagination
  Future<void> loadMore() async {
    if (!_hasNextPage || _isLoading || _isLoadingMore) return;

    _currentPage++;
    _isLoadingMore = true;
    notifyListeners();

    try {
      _log.i('[UserAdminProvider] Load more users page: $_currentPage');
      final result = await _repository.getUsers(page: _currentPage);

      _users.addAll(result.users);
      _hasNextPage = result.hasNextPage;
      _log.i('[UserAdminProvider] More users loaded: ${result.users.length}, hasNextPage: $_hasNextPage');
    } catch (e, st) {
      _currentPage--; // Rollback
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[UserAdminProvider] Failed to load more users',
          error: e, stackTrace: st);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Create new user
  Future<UserAdminModel?> createUser(CreateUserRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[UserAdminProvider] Creating user: ${request.email}');
      final result = await _repository.createUser(request);
      _users.insert(0, result); // Insert at beginning of list
      _log.i('[UserAdminProvider] User created successfully: ${result.id}');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[UserAdminProvider] Failed to create user',
          error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update existing user
  Future<UserAdminModel?> updateUser(
      int userId, UpdateUserRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[UserAdminProvider] Updating user: $userId');
      final result = await _repository.updateUser(userId, request);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = result;
      }
      _log.i('[UserAdminProvider] User updated successfully: $userId');
      return result;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[UserAdminProvider] Failed to update user',
          error: e, stackTrace: st);
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Soft delete user
  Future<bool> deleteUser(int userId) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[UserAdminProvider] Deleting user: $userId');
      await _repository.deleteUser(userId);

      // DELETE tidak return data, fetch detail untuk dapat deleted_at
      final updated = await _repository.getUserDetail(userId);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updated;
      }

      _log.i('[UserAdminProvider] User deleted successfully: $userId');
      return true;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[UserAdminProvider] Failed to delete user',
          error: e, stackTrace: st);
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Restore soft deleted user
  Future<bool> restoreUser(int userId) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[UserAdminProvider] Restoring user: $userId');
      final restored = await _repository.restoreUser(userId);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = restored;
      }

      _log.i('[UserAdminProvider] User restored successfully: $userId');
      return true;
    } catch (e, st) {
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[UserAdminProvider] Failed to restore user',
          error: e, stackTrace: st);
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
