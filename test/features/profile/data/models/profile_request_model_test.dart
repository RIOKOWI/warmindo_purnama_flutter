import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/profile/data/models/profile_request_model.dart';

void main() {
  group('UpdateProfileRequest', () {
    test('toJson harus mengembalikan map yang benar', () {
      const request = UpdateProfileRequest(
        name: 'rio customer',
        email: '1123150059@global.ac.id',
        phone: '0895384650474',
      );
      final result = request.toJson();
      expect(result['name'], 'rio customer');
      expect(result['email'], '1123150059@global.ac.id');
      expect(result['phone'], '0895384650474');
    });

    test('toJson tanpa phone harus tidak include phone', () {
      const request = UpdateProfileRequest(
        name: 'rio customer',
        email: '1123150059@global.ac.id',
      );
      final result = request.toJson();
      expect(result.containsKey('phone'), false);
    });

    test('props harus berisi semua field', () {
      const request = UpdateProfileRequest(
        name: 'rio customer',
        email: '1123150059@global.ac.id',
        phone: '0895384650474',
      );
      expect(request.props.length, 3);
      expect(request.props.contains('rio customer'), true);
    });
  });

  group('UpdatePasswordRequest', () {
    test('toJson harus mengembalikan map yang benar', () {
      const request = UpdatePasswordRequest(
        currentPassword: 'Rioganteng123@',
        password: 'Aselole123@',
        passwordConfirmation: 'Aselole123@',
      );
      final result = request.toJson();
      expect(result['current_password'], 'Rioganteng123@');
      expect(result['password'], 'Aselole123@');
      expect(result['password_confirmation'], 'Aselole123@');
    });

    test('props harus berisi semua field', () {
      const request = UpdatePasswordRequest(
        currentPassword: 'Rioganteng123@',
        password: 'Aselole123@',
        passwordConfirmation: 'Aselole123@',
      );
      expect(request.props.length, 3);
    });
  });
}
