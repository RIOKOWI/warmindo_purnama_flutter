import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

/// Remote data source for product API calls
class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// Get all products from API
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.products);

      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List;

      _log.d('[ProductRemoteDataSource] Fetched ${list.length} products');

      return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e, st) {
      _log.e('[ProductRemoteDataSource] Failed to fetch products', error: e, stackTrace: st);
      throw Exception('Gagal mengambil produk: ${e.message}');
    } catch (e, st) {
      _log.e('[ProductRemoteDataSource] Unknown error', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get all categories from API
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.categories);

      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List;

      _log.d('[ProductRemoteDataSource] Fetched ${list.length} categories');

      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e, st) {
      _log.e('[ProductRemoteDataSource] Failed to fetch categories', error: e, stackTrace: st);
      throw Exception('Gagal mengambil kategori: ${e.message}');
    } catch (e, st) {
      _log.e('[ProductRemoteDataSource] Unknown error', error: e, stackTrace: st);
      rethrow;
    }
  }
}