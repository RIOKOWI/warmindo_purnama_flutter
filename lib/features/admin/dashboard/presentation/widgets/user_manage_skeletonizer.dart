import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/user_admin_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/widgets/user_admin_tile.dart';

/// Fake data for skeleton loader
final fakeUsers = List.generate(7, (i) => UserAdminModel(
  id: i,
  name: 'User Name',
  email: 'user@example.com',
  phone: '081234567890',
  role: 'kasir',
  createdAt: '2024-01-01',
  updatedAt: '2024-01-01',
));

/// Skeletonizer widget for user list
class UserManageSkeletonizer extends StatelessWidget {
  const UserManageSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeUsers.length,
        itemBuilder: (context, index) {
          final user = fakeUsers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UserAdminTile(
              user: user,
              onEdit: () {},
            ),
          );
        },
      ),
    );
  }
}