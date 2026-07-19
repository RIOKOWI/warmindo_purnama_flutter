import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import '../../data/models/category_request_model.dart';

/// Abstract repository untuk admin category operations
abstract class CategoryAdminRepository {
  /// Create new category
  Future<CategoryModel> createCategory(CategoryRequestModel request);

  /// Update existing category
  Future<CategoryModel> updateCategory(int id, CategoryRequestModel request);

  /// Delete category
  Future<void> deleteCategory(int id);
}