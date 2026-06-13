import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/errors/error_handler.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import '../models/profile_model.dart';
import '../models/profile_request_model.dart';

/// Remote data source for profile API calls
class ProfileRemoteDataSource {
  final DioClient _dioClient;
  final Logger _log = Logger();

  ProfileRemoteDataSource(this._dioClient);

  /// Get current user profile
  Future<ProfileModel> getProfile() async {
    _log.i('[ProfileRemoteDataSource] Fetching profile');
    try {
      final response = await _dioClient.dio.get(ApiConstants.profile);
      final data = response.data as Map<String, dynamic>;
      _log.i('[ProfileRemoteDataSource] Profile fetched successfully');
      return ProfileModel.fromJson(data['data']);
    } catch (e, st) {
      _log.e('[ProfileRemoteDataSource] Failed to get profile', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Update current user profile
  Future<ProfileModel> updateProfile(UpdateProfileRequest request) async {
    _log.i('[ProfileRemoteDataSource] Updating profile');
    try {
      final response = await _dioClient.dio.patch(
        ApiConstants.profile,
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      _log.i('[ProfileRemoteDataSource] Profile updated successfully');
      return ProfileModel.fromJson(data['data']);
    } catch (e, st) {
      _log.e('[ProfileRemoteDataSource] Failed to update profile', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Update current user password
  Future<ProfileModel> updatePassword(UpdatePasswordRequest request) async {
    _log.i('[ProfileRemoteDataSource] Updating password');
    try {
      final response = await _dioClient.dio.patch(
        ApiConstants.profilePassword,
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      _log.i('[ProfileRemoteDataSource] Password updated successfully');
      return ProfileModel.fromJson(data['data']);
    } catch (e, st) {
      _log.e('[ProfileRemoteDataSource] Failed to update password', error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }
}
