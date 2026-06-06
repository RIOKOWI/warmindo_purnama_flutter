import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import '../models/user_admin_model.dart';
import '../models/user_list_model.dart';
import '../models/user_request_model.dart';

/// Remote data source untuk admin user operations
class UserAdminDataSource {
  UserAdminDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// Get paginated list of users
  Future<UserListModel> getUsers({int page = 1}) async {
    try {
      _log.i('[UserAdminDataSource] Fetch users page: $page');

      final response = await _dioClient.dio.get(
        ApiConstants.adminUsers,
        queryParameters: {'page': page},
      );

      _log.i('[UserAdminDataSource] Users fetched successfully');
      return UserListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[UserAdminDataSource] DioException saat fetch users',
          error: e, stackTrace: st);
      final message = e.response?.data?['message'] as String?;
      throw Exception(message ?? 'Gagal mengambil data user');
    } catch (e, st) {
      _log.e('[UserAdminDataSource] Unknown error saat fetch users',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get single user detail
  Future<UserAdminModel> getUserDetail(int userId) async {
    try {
      _log.i('[UserAdminDataSource] Fetch user detail: $userId');

      final response = await _dioClient.dio.get(
        ApiConstants.adminUserDetail(userId),
      );

      _log.i('[UserAdminDataSource] User detail fetched: $userId');
      return UserAdminModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[UserAdminDataSource] DioException saat fetch user detail: $userId',
          error: e, stackTrace: st);
      final message = e.response?.data?['message'] as String?;
      throw Exception(message ?? 'Gagal mengambil detail user');
    } catch (e, st) {
      _log.e('[UserAdminDataSource] Unknown error saat fetch user detail: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Create new user
  Future<UserAdminModel> createUser(CreateUserRequestModel request) async {
    try {
      _log.i('[UserAdminDataSource] Create user: ${request.email}');

      final response = await _dioClient.dio.post(
        ApiConstants.adminUsers,
        data: request.toJson(),
      );

      _log.i('[UserAdminDataSource] User created successfully');
      return UserAdminModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[UserAdminDataSource] DioException saat create user',
          error: e, stackTrace: st);
      final message = e.response?.data?['message'] as String?;
      throw Exception(message ?? 'Gagal membuat user');
    } catch (e, st) {
      _log.e('[UserAdminDataSource] Unknown error saat create user',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Update existing user
  Future<UserAdminModel> updateUser(
      int userId, UpdateUserRequestModel request) async {
    try {
      _log.i('[UserAdminDataSource] Update user: $userId');

      final response = await _dioClient.dio.put(
        ApiConstants.adminUserDetail(userId),
        data: request.toJson(),
      );

      _log.i('[UserAdminDataSource] User updated successfully: $userId');
      return UserAdminModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[UserAdminDataSource] DioException saat update user: $userId',
          error: e, stackTrace: st);
      final message = e.response?.data?['message'] as String?;
      throw Exception(message ?? 'Gagal mengupdate user');
    } catch (e, st) {
      _log.e('[UserAdminDataSource] Unknown error saat update user: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Soft delete user
  Future<void> deleteUser(int userId) async {
    try {
      _log.i('[UserAdminDataSource] Soft delete user: $userId');

      await _dioClient.dio.delete(ApiConstants.adminUserDetail(userId));

      _log.i('[UserAdminDataSource] User soft deleted: $userId');
    } on DioException catch (e, st) {
      _log.e('[UserAdminDataSource] DioException saat delete user: $userId',
          error: e, stackTrace: st);
      final message = e.response?.data?['message'] as String?;
      throw Exception(message ?? 'Gagal menghapus user');
    } catch (e, st) {
      _log.e('[UserAdminDataSource] Unknown error saat delete user: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Restore soft deleted user
  Future<UserAdminModel> restoreUser(int userId) async {
    try {
      _log.i('[UserAdminDataSource] Restore user: $userId');

      final response = await _dioClient.dio.post(
        ApiConstants.adminUserRestore(userId),
      );

      _log.i('[UserAdminDataSource] User restored successfully: $userId');
      return UserAdminModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[UserAdminDataSource] DioException saat restore user: $userId',
          error: e, stackTrace: st);
      final message = e.response?.data?['message'] as String?;
      throw Exception(message ?? 'Gagal merestore user');
    } catch (e, st) {
      _log.e('[UserAdminDataSource] Unknown error saat restore user: $userId',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}
