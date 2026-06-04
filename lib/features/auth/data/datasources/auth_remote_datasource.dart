import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication API calls
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logout);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.me);
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['data']);
    } catch (e) {
      throw Exception('Get user failed: $e');
    }
  }
}