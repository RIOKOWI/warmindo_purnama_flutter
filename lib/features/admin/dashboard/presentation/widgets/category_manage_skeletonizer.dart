import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';

/// Fake data for skeleton loading
final fakeCategories = List.generate(
  7,
  (i) => CategoryModel(id: i, name: 'Kategori ${i + 1}'),
);

/// Skeletonizer widget for category list
class CategoryManageSkeletonizer extends StatelessWidget {
  const CategoryManageSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeCategories.length,
        itemBuilder: (context, index) {
          final category = fakeCategories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dark, width: 3),
                boxShadow: const [BoxShadow(color: AppColors.dark, offset: Offset(4, 4), blurRadius: 0)],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  category.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.info, width: 2),
                      ),
                      child: const Icon(Icons.edit, color: AppColors.info, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error, width: 2),
                      ),
                      child: const Icon(Icons.delete, color: AppColors.error, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}