import 'package:logger/logger.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/profile_request_model.dart';
import 'profile_repository.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  final Logger _log = Logger();

  ProfileRepositoryImpl({required ProfileRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<ProfileModel> getProfile() async {
    _log.i('[ProfileRepository] Getting profile');
    try {
      final result = await _dataSource.getProfile();
      _log.i('[ProfileRepository] Profile retrieved successfully');
      return result;
    } catch (e, st) {
      _log.e('[ProfileRepository] Failed to get profile', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequest request) async {
    _log.i('[ProfileRepository] Updating profile');
    try {
      final result = await _dataSource.updateProfile(request);
      _log.i('[ProfileRepository] Profile updated successfully');
      return result;
    } catch (e, st) {
      _log.e('[ProfileRepository] Failed to update profile', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updatePassword(UpdatePasswordRequest request) async {
    _log.i('[ProfileRepository] Updating password');
    try {
      final result = await _dataSource.updatePassword(request);
      _log.i('[ProfileRepository] Password updated successfully');
      return result;
    } catch (e, st) {
      _log.e('[ProfileRepository] Failed to update password', error: e, stackTrace: st);
      rethrow;
    }
  }
}