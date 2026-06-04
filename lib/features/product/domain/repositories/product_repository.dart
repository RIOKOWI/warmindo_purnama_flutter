import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

/// Abstract repository interface for product operations
abstract class ProductRepository {
  /// Get all categories
  Future<List<CategoryModel>> getCategories();

  /// Get all products (optionally filtered by category)
  Future<List<ProductModel>> getProducts({int? categoryId});
}
