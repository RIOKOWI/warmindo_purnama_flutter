import '../../data/models/user_admin_model.dart';
import '../../data/models/user_list_model.dart';
import '../../data/models/user_request_model.dart';

/// Abstract repository untuk admin user operations
abstract class UserAdminRepository {
  /// Get paginated list of users
  Future<UserListModel> getUsers({int page = 1});

  /// Get single user detail
  Future<UserAdminModel> getUserDetail(int userId);

  /// Create new user
  Future<UserAdminModel> createUser(CreateUserRequestModel request);

  /// Update existing user
  Future<UserAdminModel> updateUser(int userId, UpdateUserRequestModel request);

  /// Soft delete user
  Future<void> deleteUser(int userId);

  /// Restore soft deleted user
  Future<UserAdminModel> restoreUser(int userId);
}