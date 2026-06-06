import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/category_model.dart';
import '../models/category_request_model.dart';

/// Remote data source untuk admin category operations
class CategoryAdminDataSource {
  CategoryAdminDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// Create new category
  Future<CategoryModel> createCategory(CategoryRequestModel request) async {
    try {
      _log.i('[CategoryAdminDataSource] Create category: ${request.name}');

      final response = await _dioClient.dio.post(
        ApiConstants.adminCategories,
        data: request.toJson(),
      );

      _log.d('[CategoryAdminDataSource] Category created successfully');
      return CategoryModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[CategoryAdminDataSource] Failed to create category',
          error: e, stackTrace: st);
      final message = e.response?.data['message'] as String?;
      throw Exception(message ?? 'Gagal membuat kategori');
    } catch (e, st) {
      _log.e('[CategoryAdminDataSource] Unknown error', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Update existing category
  Future<CategoryModel> updateCategory(int id, CategoryRequestModel request) async {
    try {
      _log.i('[CategoryAdminDataSource] Update category: $id');

      final response = await _dioClient.dio.put(
        '${ApiConstants.adminCategories}/$id',
        data: request.toJson(),
      );

      _log.d('[CategoryAdminDataSource] Category updated successfully');
      return CategoryModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[CategoryAdminDataSource] Failed to update category',
          error: e, stackTrace: st);
      final message = e.response?.data['message'] as String?;
      throw Exception(message ?? 'Gagal mengupdate kategori');
    } catch (e, st) {
      _log.e('[CategoryAdminDataSource] Unknown error', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Delete category
  Future<void> deleteCategory(int id) async {
    try {
      _log.i('[CategoryAdminDataSource] Delete category: $id');

      await _dioClient.dio.delete('${ApiConstants.adminCategories}/$id');

      _log.d('[CategoryAdminDataSource] Category deleted successfully');
    } on DioException catch (e, st) {
      _log.e('[CategoryAdminDataSource] Failed to delete category',
          error: e, stackTrace: st);
      final message = e.response?.data['message'] as String?;
      throw Exception(message ?? 'Gagal menghapus kategori');
    } catch (e, st) {
      _log.e('[CategoryAdminDataSource] Unknown error', error: e, stackTrace: st);
      rethrow;
    }
  }
}