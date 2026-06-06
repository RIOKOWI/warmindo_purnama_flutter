import 'package:logger/logger.dart';
import '../../data/datasources/category_admin_datasource.dart';
import '../../data/models/category_request_model.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import 'category_admin_repository.dart';

/// Implementation dari CategoryAdminRepository
class CategoryAdminRepositoryImpl implements CategoryAdminRepository {
  CategoryAdminRepositoryImpl({required CategoryAdminDataSource dataSource})
      : _dataSource = dataSource;

  final CategoryAdminDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<CategoryModel> createCategory(CategoryRequestModel request) async {
    try {
      return await _dataSource.createCategory(request);
    } catch (e, st) {
      _log.e('[CategoryAdminRepositoryImpl] Failed to create category',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<CategoryModel> updateCategory(int id, CategoryRequestModel request) async {
    try {
      return await _dataSource.updateCategory(id, request);
    } catch (e, st) {
      _log.e('[CategoryAdminRepositoryImpl] Failed to update category',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _dataSource.deleteCategory(id);
    } catch (e, st) {
      _log.e('[CategoryAdminRepositoryImpl] Failed to delete category',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}