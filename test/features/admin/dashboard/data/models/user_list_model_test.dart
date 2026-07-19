import 'package:flutter_test/flutter_test.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/user_list_model.dart';

void main() {
  group('UserListModel', () {
    final tJson = {
      'success': true,
      'message': 'Users retrieved successfully',
      'data': {
        'data': [
          {
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
          },
          {
            'id': 308,
            'name': 'popowi',
            'email': 'giog1733@gmail.com',
            'phone': 'string',
            'role': 'kasir',
            'fcm_token': null,
            'email_verified_at': null,
            'created_at': '2026-05-17T01:09:19.000000Z',
            'updated_at': '2026-05-17T09:35:52.000000Z',
            'deleted_at': null,
          },
        ],
        'meta': {
          'current_page': 1,
          'last_page': 1,
          'per_page': 15,
          'total': 2,
        },
      },
    };

    final tJsonMultiPage = {
      'success': true,
      'message': 'Users retrieved successfully',
      'data': {
        'data': [
          {
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
          },
        ],
        'meta': {
          'current_page': 1,
          'last_page': 3,
          'per_page': 15,
          'total': 45,
        },
      },
    };

    test('fromJson parse dua level data[data][data] dan meta', () {
      final result = UserListModel.fromJson(tJson);

      expect(result.users.length, 2);
      expect(result.users[0].id, 309);
      expect(result.users[0].name, 'wancoy');
      expect(result.users[1].id, 308);
      expect(result.currentPage, 1);
      expect(result.lastPage, 1);
      expect(result.total, 2);
    });

    test('hasNextPage true jika currentPage < lastPage', () {
      final result = UserListModel.fromJson(tJsonMultiPage);

      expect(result.hasNextPage, true);
      expect(result.currentPage, 1);
      expect(result.lastPage, 3);
    });

    test('hasNextPage false jika sama', () {
      final result = UserListModel.fromJson(tJson);

      expect(result.hasNextPage, false);
      expect(result.currentPage, 1);
      expect(result.lastPage, 1);
    });

    test('props mencakup semua field', () {
      final result = UserListModel.fromJson(tJson);

      expect(result.props, contains(result.users));
      expect(result.props, contains(result.currentPage));
      expect(result.props, contains(result.lastPage));
      expect(result.props, contains(result.total));
    });
  });
}