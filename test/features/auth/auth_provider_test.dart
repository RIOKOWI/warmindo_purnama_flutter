import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warmindo_purnama_flutter/features/auth/domain/auth_status.dart';
import 'package:warmindo_purnama_flutter/features/auth/data/models/user_model.dart';
import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';

void main() {
  setUp(() {
    // Set mock values for flutter_secure_storage in test environment
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('UserModel', () {
    test('fromJson parses user data correctly', () {
      // Arrange
      final json = {
        'id': 4,
        'name': 'rio achyar',
        'email': '1123150059@global.ac.id',
        'phone': '0895384650474',
        'role': 'customer',
        'email_verified_at': null,
        'created_at': '2026-05-15T01:51:22.000000Z',
        'updated_at': '2026-05-15T01:51:22.000000Z',
      };

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.id, 4);
      expect(user.name, 'rio achyar');
      expect(user.email, '1123150059@global.ac.id');
      expect(user.phone, '0895384650474');
      expect(user.role, 'customer');
      expect(user.emailVerifiedAt, isNull);
    });

    test('toJson returns correct map', () {
      // Arrange
      final user = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@email.com',
        phone: '08123456789',
        role: 'admin',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Test User');
      expect(json['role'], 'admin');
    });

    test('isCustomer returns true for customer role', () {
      final user = UserModel(
        id: 1,
        name: 'Customer',
        email: 'test@test.com',
        phone: '123',
        role: 'customer',
        createdAt: '2024',
        updatedAt: '2024',
      );
      expect(user.isCustomer, true);
      expect(user.isKasir, false);
      expect(user.isAdmin, false);
    });

    test('isKasir returns true for kasir role', () {
      final user = UserModel(
        id: 1,
        name: 'Kasir',
        email: 'test@test.com',
        phone: '123',
        role: 'kasir',
        createdAt: '2024',
        updatedAt: '2024',
      );
      expect(user.isKasir, true);
      expect(user.isCustomer, false);
      expect(user.isAdmin, false);
    });

    test('isAdmin returns true for admin role', () {
      final user = UserModel(
        id: 1,
        name: 'Admin',
        email: 'test@test.com',
        phone: '123',
        role: 'admin',
        createdAt: '2024',
        updatedAt: '2024',
      );
      expect(user.isAdmin, true);
      expect(user.isCustomer, false);
      expect(user.isKasir, false);
    });
  });

  group('SecureStorage', () {
    late SecureStorage storage;

    setUp(() {
      storage = SecureStorage();
    });

    test('saveToken and getToken work correctly', () async {
      const testToken = 'test-token-123';
      await storage.saveToken(testToken);
      final result = await storage.getToken();
      expect(result, testToken);
    });

    test('getToken returns null if not saved', () async {
      final result = await storage.getToken();
      expect(result, isNull);
    });

    test('saveRole and getRole work correctly', () async {
      const testRole = 'customer';
      await storage.saveRole(testRole);
      final result = await storage.getRole();
      expect(result, testRole);
    });

    test('clearAll removes all stored data', () async {
      await storage.saveToken('test-token');
      await storage.saveRole('kasir');
      await storage.clearAll();
      expect(await storage.getToken(), isNull);
      expect(await storage.getRole(), isNull);
    });

    test('hasToken returns true when token exists', () async {
      await storage.saveToken('test-token');
      expect(await storage.hasToken(), true);
    });

    test('hasToken returns false when no token', () async {
      expect(await storage.hasToken(), false);
    });

    test('deleteToken removes only token', () async {
      await storage.saveToken('test-token');
      await storage.saveRole('admin');
      await storage.deleteToken();
      expect(await storage.getToken(), isNull);
      expect(await storage.getRole(), 'admin');
    });
  });

  group('AuthStatus enum', () {
    test('has correct values', () {
      expect(AuthStatus.values.length, 5);
      expect(AuthStatus.initial.index, 0);
      expect(AuthStatus.loading.index, 1);
      expect(AuthStatus.authenticated.index, 2);
      expect(AuthStatus.unauthenticated.index, 3);
      expect(AuthStatus.error.index, 4);
    });
  });
}