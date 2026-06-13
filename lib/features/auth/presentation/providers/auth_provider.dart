import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import '../../../auth/domain/auth_status.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/notification_service.dart';

/// Authentication provider using ChangeNotifier pattern.
///
/// Manages login, register, logout, and auto-login functionality.
/// FCM token registration is handled after a successful login session.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final DioClient _dioClient;
  final Logger _log = Logger();

  AuthProvider(this._authRepository, this._dioClient);

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  /// Current authentication status
  AuthStatus get status => _status;

  /// Current authenticated user
  UserModel? get user => _currentUser;

  /// Error message from last failed request
  String? get errorMessage => _errorMessage;

  /// Current user role ('customer' | 'kasir' | 'admin')
  String? get role => _currentUser?.role;

  /// Current user name
  String? get name => _currentUser?.name;

  /// Whether a request is in progress
  bool get isLoading => _status == AuthStatus.loading;

  /// Whether user is authenticated
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      try {
        final user = await _authRepository.getCurrentUser();
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } catch (e) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = null;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: password,
      );

      _currentUser = user;
      await _saveSession();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      _currentUser = user;
      await _saveSession();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      if (e is AppException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authRepository.logout();
    } catch (e) {
      // Best effort - continue even if logout request fails
      _log.w('[AuthProvider] Logout request failed: $e');
    }

    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Menyimpan sesi login dan menginisialisasi FCM.
  ///
  /// FCM init dilakukan setelah token tersimpan.
  /// Jika FCM gagal, login tetap berhasil (silent fail).
  Future<void> _saveSession() async {
    // Init FCM — WAJIB setelah token tersimpan, WAJIB wrapped try-catch
    try {
      await NotificationService.initialize(
        onTokenReceived: (fcmToken) async {
          await _dioClient.dio.patch(
            ApiConstants.fcmToken,
            data: {'fcm_token': fcmToken},
          );
          _log.i('[AuthProvider] FCM token berhasil dikirim ke backend');
        },
      );
    } catch (e, st) {
      // Silent fail — login tetap sukses meski FCM gagal
      _log.w('[AuthProvider] FCM init gagal (non-critical): $e\n$st');
    }

    // Set status authenticated SETELAH FCM setup (atau setelah FCM gagal)
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}