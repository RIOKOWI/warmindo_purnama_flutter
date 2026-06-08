import '../../data/models/profile_model.dart';
import '../../data/models/profile_request_model.dart';

/// Abstract interface for profile repository
abstract class ProfileRepository {
  /// Get current user profile
  Future<ProfileModel> getProfile();

  /// Update current user profile
  Future<ProfileModel> updateProfile(UpdateProfileRequest request);

  /// Update current user password
  Future<ProfileModel> updatePassword(UpdatePasswordRequest request);
}