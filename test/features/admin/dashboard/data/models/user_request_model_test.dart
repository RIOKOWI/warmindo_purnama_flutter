import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/user_request_model.dart';

void main() {
  group('CreateUserRequestModel', () {
    test('toJson include password dan password_confirmation', () {
      final request = CreateUserRequestModel(
        name: 'gofar',
        email: 'hilman@gmail.com',
        phone: '0897654333',
        role: 'customer',
        password: 'Hilman123@',
        passwordConfirmation: 'Hilman123@',
      );

      final json = request.toJson();

      expect(json['name'], 'gofar');
      expect(json['email'], 'hilman@gmail.com');
      expect(json['phone'], '0897654333');
      expect(json['role'], 'customer');
      expect(json['password'], 'Hilman123@');
      expect(json['password_confirmation'], 'Hilman123@');
    });

    test('key password_confirmation ada di toJson', () {
      final request = CreateUserRequestModel(
        name: 'test',
        email: 'test@test.com',
        phone: '123',
        role: 'kasir',
        password: 'Test123@',
        passwordConfirmation: 'Test123@',
      );

      final json = request.toJson();

      expect(json.containsKey('password_confirmation'), true);
      expect(json['password_confirmation'], 'Test123@');
    });

    test('props mencakup name, email, phone, role', () {
      final request = CreateUserRequestModel(
        name: 'test',
        email: 'test@test.com',
        phone: '123',
        role: 'kasir',
        password: 'Test123@',
        passwordConfirmation: 'Test123@',
      );

      expect(request.props, contains('test'));
      expect(request.props, contains('test@test.com'));
      expect(request.props, contains('123'));
      expect(request.props, contains('kasir'));
    });
  });

  group('UpdateUserRequestModel', () {
    test('toJson TIDAK include password', () {
      final request = UpdateUserRequestModel(
        name: 'hilman',
        email: 'hilman@gmail.com',
        phone: '08688756737',
        role: 'kasir',
      );

      final json = request.toJson();

      expect(json['name'], 'hilman');
      expect(json['email'], 'hilman@gmail.com');
      expect(json['phone'], '08688756737');
      expect(json['role'], 'kasir');
      expect(json.containsKey('password'), false);
      expect(json.containsKey('password_confirmation'), false);
    });

    test('props mencakup name, email, phone, role', () {
      final request = UpdateUserRequestModel(
        name: 'test',
        email: 'test@test.com',
        phone: '123',
        role: 'kasir',
      );

      expect(request.props, contains('test'));
      expect(request.props, contains('test@test.com'));
      expect(request.props, contains('123'));
      expect(request.props, contains('kasir'));
    });
  });
}