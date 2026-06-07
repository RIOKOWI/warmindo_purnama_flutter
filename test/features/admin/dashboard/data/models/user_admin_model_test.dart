import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/user_admin_model.dart';

void main() {
  group('UserAdminModel', () {
    final tJson = {
      'id': 309,
      'name': 'wancoy',
      'email': 'warkopolim@gmail.com',
      'phone': '089678574893',
      'role': 'admin',
      'fcm_token': null,
      'email_verified_at': null,
      'created_at': '2026-05-17T09:39:25.000000Z',
      'updated_at': '2026-05-17T09:43:28.000000Z',
      'deleted_at': null,
    };

    final tJsonDeleted = {
      'id': 308,
      'name': 'popowi',
      'email': 'giog1733@gmail.com',
      'phone': 'string',
      'role': 'kasir',
      'fcm_token': null,
      'email_verified_at': null,
      'created_at': '2026-05-17T01:09:19.000000Z',
      'updated_at': '2026-05-17T09:35:52.000000Z',
      'deleted_at': '2026-05-17T10:00:00.000000Z',
    };

    test('fromJson menghasilkan model yang benar', () {
      final result = UserAdminModel.fromJson(tJson);

      expect(result.id, 309);
      expect(result.name, 'wancoy');
      expect(result.email, 'warkopolim@gmail.com');
      expect(result.phone, '089678574893');
      expect(result.role, 'admin');
    });

    test('isDeleted true jika deletedAt tidak null', () {
      final result = UserAdminModel.fromJson(tJsonDeleted);

      expect(result.isDeleted, true);
      expect(result.isActive, false);
    });

    test('isActive true jika deletedAt null', () {
      final result = UserAdminModel.fromJson(tJson);

      expect(result.isActive, true);
      expect(result.isDeleted, false);
    });

    test('fcmToken nullable - tidak crash jika JSON null', () {
      final result = UserAdminModel.fromJson(tJson);

      expect(result.fcmToken, isNull);
    });

    test('toJson menghasilkan map yang benar', () {
      final model = UserAdminModel.fromJson(tJson);
      final json = model.toJson();

      expect(json['id'], 309);
      expect(json['name'], 'wancoy');
      expect(json['email'], 'warkopolim@gmail.com');
      expect(json['role'], 'admin');
      expect(json['fcm_token'], isNull);
      expect(json['deleted_at'], isNull);
    });
  });
}