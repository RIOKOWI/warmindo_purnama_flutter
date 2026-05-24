import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorage service for storing sensitive data like tokens and roles.
/// Uses RSA OAEP + AES-GCM encryption on Android and Keychain on iOS.
class SecureStorage {
  SecureStorage() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  late final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Save user role ('customer' | 'kasir' | 'admin')
  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  /// Get user role
  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  /// Clear all stored data (token and role)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}