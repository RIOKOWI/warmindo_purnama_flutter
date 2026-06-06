import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import '../../data/models/product_request_model.dart';

/// Abstract repository untuk admin product operations
abstract class ProductAdminRepository {
  /// Create new product
  Future<ProductModel> createProduct(ProductRequestModel request);

  /// Update existing product
  Future<ProductModel> updateProduct(int id, ProductRequestModel request);

  /// Delete product
  Future<void> deleteProduct(int id);
}