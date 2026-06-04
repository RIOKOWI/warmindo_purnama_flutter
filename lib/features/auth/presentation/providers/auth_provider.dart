import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../../auth/domain/auth_status.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/data/models/user_model.dart';

/// Authentication provider using ChangeNotifier pattern.
///
/// Manages login, register, logout, and auto-login functionality.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final Logger _log = Logger();

  AuthProvider(this._authRepository);

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
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
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
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
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

  /// Parse error to Indonesian error message
  String _parseError(dynamic e) {
    if (e is DioException) {
      // Try to get message from response data first
      if (e.response?.data is Map) {
        final message = (e.response!.data as Map)['message'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }

      // Fallback to status code based messages
      switch (e.response?.statusCode) {
        case 401:
          return 'Email atau password salah.';
        case 422:
          return 'Data tidak valid. Periksa kembali inputan Anda.';
        case 500:
          return 'Server sedang bermasalah. Coba lagi nanti.';
        default:
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            return 'Tidak ada koneksi internet.';
          }
          return 'Terjadi kesalahan. Coba lagi.';
      }
    }
    return e.toString();
  }
}