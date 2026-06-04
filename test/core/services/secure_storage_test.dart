import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';

void main() {
  setUp(() {
    // Set mock values for flutter_secure_storage in test environment
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('SecureStorage', () {
    group('saveToken / getToken', () {
      test('saveToken menyimpan token dan getToken mengembalikannya', () async {
        // Arrange
        const testToken = 'test-token-123';
        final storage = SecureStorage();

        // Act
        await storage.saveToken(testToken);
        final result = await storage.getToken();

        // Assert
        expect(result, testToken);
      });

      test('getToken return null jika belum pernah disimpan', () async {
        // Arrange
        final storage = SecureStorage();

        // Act
        final result = await storage.getToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('saveRole / getRole', () {
      test('saveRole menyimpan role dan getRole mengembalikannya', () async {
        // Arrange
        const testRole = 'customer';
        final storage = SecureStorage();

        // Act
        await storage.saveRole(testRole);
        final result = await storage.getRole();

        // Assert
        expect(result, testRole);
      });

      test('getRole return null jika belum pernah disimpan', () async {
        // Arrange
        final storage = SecureStorage();

        // Act
        final result = await storage.getRole();

        // Assert
        expect(result, isNull);
      });
    });

    group('clearAll', () {
      test('clearAll menghapus token', () async {
        // Arrange
        final storage = SecureStorage();
        await storage.saveToken('test-token');

        // Act
        await storage.clearAll();
        final result = await storage.getToken();

        // Assert
        expect(result, isNull);
      });

      test('clearAll menghapus role', () async {
        // Arrange
        final storage = SecureStorage();
        await storage.saveRole('admin');

        // Act
        await storage.clearAll();
        final result = await storage.getRole();

        // Assert
        expect(result, isNull);
      });

      test('clearAll menghapus semua key sekaligus', () async {
        // Arrange
        final storage = SecureStorage();
        await storage.saveToken('test-token');
        await storage.saveRole('kasir');

        // Act
        await storage.clearAll();

        // Assert
        final tokenResult = await storage.getToken();
        final roleResult = await storage.getRole();
        expect(tokenResult, isNull);
        expect(roleResult, isNull);
      });
    });
  });
}