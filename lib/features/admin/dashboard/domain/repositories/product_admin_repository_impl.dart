import 'package:logger/logger.dart';
import '../../data/datasources/product_admin_datasource.dart';
import '../../data/models/product_request_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import 'product_admin_repository.dart';

/// Implementation dari ProductAdminRepository
class ProductAdminRepositoryImpl implements ProductAdminRepository {
  ProductAdminRepositoryImpl({required ProductAdminDataSource dataSource})
      : _dataSource = dataSource;

  final ProductAdminDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<ProductModel> createProduct(ProductRequestModel request) async {
    try {
      return await _dataSource.createProduct(request);
    } catch (e, st) {
      _log.e('[ProductAdminRepositoryImpl] Failed to create product',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<ProductModel> updateProduct(int id, ProductRequestModel request) async {
    try {
      return await _dataSource.updateProduct(id, request);
    } catch (e, st) {
      _log.e('[ProductAdminRepositoryImpl] Failed to update product',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _dataSource.deleteProduct(id);
    } catch (e, st) {
      _log.e('[ProductAdminRepositoryImpl] Failed to delete product',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}