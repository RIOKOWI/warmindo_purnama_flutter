import '../../data/models/user_model.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Register new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Logout user
  Future<void> logout();

  /// Get current authenticated user
  Future<UserModel> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}