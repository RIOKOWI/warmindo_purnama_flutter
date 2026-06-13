import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import '../../data/models/user_admin_model.dart';

/// Widget tile untuk menampilkan data user dalam list
class UserAdminTile extends StatelessWidget {
  final UserAdminModel user;
  final VoidCallback onEdit;

  const UserAdminTile({
    super.key,
    required this.user,
    required this.onEdit,
  });

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.accent;
      case 'kasir':
        return AppColors.info;
      case 'customer':
        return AppColors.success;
      default:
        return AppColors.textLight;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'kasir':
        return 'Kasir';
      case 'customer':
        return 'Customer';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _roleColor(user.role);

    return Opacity(
      opacity: user.isDeleted ? 0.5 : 1.0,
      child: NeoCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: roleColor, width: 2),
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: AppTextStyles.title.copyWith(color: roleColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: AppTextStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: roleColor, width: 2),
                        ),
                        child: Text(
                          _roleLabel(user.role),
                          style: AppTextStyles.caption.copyWith(
                            color: roleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (user.isDeleted) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.textLight, width: 2),
                          ),
                          child: Text(
                            'Nonaktif',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!user.isDeleted) ...[
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: AppColors.info, size: 20),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}