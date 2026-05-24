import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';
import 'package:warmindo_purnama_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import 'auth_repository.dart';

/// Implementation of AuthRepository using remote data source and secure storage
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _remoteDataSource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    // Save token from response
    if (response.data != null) {
      await _secureStorage.saveToken(response.data!.token);
    }

    return response.data!.user;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save token from response
    if (response.data != null) {
      await _secureStorage.saveToken(response.data!.token);
    }

    return response.data!.user;
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _secureStorage.deleteToken();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasToken();
  }
}