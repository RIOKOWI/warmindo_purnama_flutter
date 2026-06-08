import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/profile/data/models/profile_model.dart';

void main() {
  group('ProfileModel', () {
    final tJson = {
      'id': 307,
      'name': 'rio achyar',
      'email': '1123150059@global.ac.id',
      'phone': '0895384650474',
      'role': 'admin',
      'email_verified_at': null,
      'created_at': '2026-05-17T00:03:10.000000Z',
      'updated_at': '2026-05-17T00:03:10.000000Z',
    };

    test('fromJson harus menghasilkan model yang benar', () {
      final result = ProfileModel.fromJson(tJson);
      expect(result.id, 307);
      expect(result.name, 'rio achyar');
      expect(result.email, '1123150059@global.ac.id');
      expect(result.phone, '0895384650474');
      expect(result.role, 'admin');
      expect(result.emailVerifiedAt, null);
    });

    test('toJson harus mengembalikan map yang benar', () {
      final model = ProfileModel.fromJson(tJson);
      final result = model.toJson();
      expect(result['id'], 307);
      expect(result['name'], 'rio achyar');
      expect(result['email'], '1123150059@global.ac.id');
      expect(result['phone'], '0895384650474');
      expect(result['role'], 'admin');
    });

    test('fromJson dengan email_verified_at tidak null', () {
      final jsonWithVerified = {
        ...tJson,
        'email_verified_at': '2026-05-17T00:03:10.000000Z',
      };
      final result = ProfileModel.fromJson(jsonWithVerified);
      expect(result.emailVerifiedAt, isNotNull);
      expect(result.emailVerifiedAt!.year, 2026);
    });

    test('props harus berisi semua field', () {
      final model = ProfileModel.fromJson(tJson);
      expect(model.props.length, 8);
      expect(model.props.contains(307), true);
      expect(model.props.contains('rio achyar'), true);
    });
  });
}
