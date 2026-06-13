import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/profile_request_model.dart';
import '../../domain/repositories/profile_repository.dart';

/// State untuk profile page
enum ProfileState { initial, loading, loaded, error }

/// Provider untuk profile management
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  final Logger _log = Logger();

  ProfileProvider({required ProfileRepository repository})
      : _repository = repository;

  ProfileState _state = ProfileState.initial;
  ProfileModel? _profile;
  String? _errorMessage;

  ProfileState get state => _state;
  ProfileModel? get profile => _profile;
  String? get errorMessage => _errorMessage;

  /// Get current user profile
  Future<void> getProfile() async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[ProfileProvider] Fetching profile');
      _profile = await _repository.getProfile();
      _state = ProfileState.loaded;
      _log.i('[ProfileProvider] Profile loaded successfully');
    } catch (e) {
      _state = ProfileState.error;
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[ProfileProvider] Failed to load profile', error: e);
    }
    notifyListeners();
  }

  /// Update current user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[ProfileProvider] Updating profile');
      final request = UpdateProfileRequest(
        name: name,
        email: email,
        phone: phone,
      );
      _profile = await _repository.updateProfile(request);
      _state = ProfileState.loaded;
      _log.i('[ProfileProvider] Profile updated successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _state = ProfileState.error;
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[ProfileProvider] Failed to update profile', error: e);
      notifyListeners();
      return false;
    }
  }

  /// Update current user password
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[ProfileProvider] Updating password');
      final request = UpdatePasswordRequest(
        currentPassword: currentPassword,
        password: newPassword,
        passwordConfirmation: confirmPassword,
      );
      _profile = await _repository.updatePassword(request);
      _state = ProfileState.loaded;
      _log.i('[ProfileProvider] Password updated successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _state = ProfileState.error;
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      _log.e('[ProfileProvider] Failed to update password', error: e);
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
