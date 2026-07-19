import 'package:logger/logger.dart';
import '../../data/datasources/user_admin_datasource.dart';
import '../../data/models/user_admin_model.dart';
import '../../data/models/user_list_model.dart';
import '../../data/models/user_request_model.dart';
import 'user_admin_repository.dart';

/// Implementation dari UserAdminRepository
class UserAdminRepositoryImpl implements UserAdminRepository {
  UserAdminRepositoryImpl({required UserAdminDataSource dataSource})
      : _dataSource = dataSource;

  final UserAdminDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<UserListModel> getUsers({int page = 1}) async {
    try {
      _log.i('[UserAdminRepositoryImpl] Get users page: $page');
      return await _dataSource.getUsers(page: page);
    } catch (e, st) {
      _log.e('[UserAdminRepositoryImpl] Error getting users',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<UserAdminModel> getUserDetail(int userId) async {
    try {
      _log.i('[UserAdminRepositoryImpl] Get user detail: $userId');
      return await _dataSource.getUserDetail(userId);
    } catch (e, st) {
      _log.e('[UserAdminRepositoryImpl] Error getting user detail: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<UserAdminModel> createUser(CreateUserRequestModel request) async {
    try {
      _log.i('[UserAdminRepositoryImpl] Create user: ${request.email}');
      return await _dataSource.createUser(request);
    } catch (e, st) {
      _log.e('[UserAdminRepositoryImpl] Error creating user',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<UserAdminModel> updateUser(
      int userId, UpdateUserRequestModel request) async {
    try {
      _log.i('[UserAdminRepositoryImpl] Update user: $userId');
      return await _dataSource.updateUser(userId, request);
    } catch (e, st) {
      _log.e('[UserAdminRepositoryImpl] Error updating user: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(int userId) async {
    try {
      _log.i('[UserAdminRepositoryImpl] Delete user: $userId');
      await _dataSource.deleteUser(userId);
    } catch (e, st) {
      _log.e('[UserAdminRepositoryImpl] Error deleting user: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<UserAdminModel> restoreUser(int userId) async {
    try {
      _log.i('[UserAdminRepositoryImpl] Restore user: $userId');
      return await _dataSource.restoreUser(userId);
    } catch (e, st) {
      _log.e('[UserAdminRepositoryImpl] Error restoring user: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}