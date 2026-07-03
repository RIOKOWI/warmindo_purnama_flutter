import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/errors/app_exception.dart';
import 'package:warmindo_purnama_flutter/core/errors/error_handler.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import 'package:warmindo_purnama_flutter/features/product/data/models/product_model.dart';
import '../models/product_request_model.dart';

/// Remote data source untuk admin product operations
/// Mendukung upload gambar untuk mobile (Android/iOS) dan web
class ProductAdminDataSource {
  ProductAdminDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// Create new product menggunakan multipart/form-data
  /// Support: Android, iOS, dan Flutter Web
  Future<ProductModel> createProduct(ProductRequestModel request) async {
    try {
      _log.i('[ProductAdminDataSource] Create product: ${request.name}');

      // Build form data dengan support cross-platform
      final formData = await _buildProductFormData(request, isCreate: true);

      _log.d('[ProductAdminDataSource] Sending POST request to ${ApiConstants.adminProducts}');

      final response = await _dioClient.dio.post(
        ApiConstants.adminProducts,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      _log.i('[ProductAdminDataSource] Product created successfully');
      _log.d('[ProductAdminDataSource] Response status: ${response.statusCode}');
      _log.d('[ProductAdminDataSource] Response data: ${response.data}');

      // Validate response structure
      final data = response.data;
      if (data == null) {
        _log.w('[ProductAdminDataSource] Response data is null');
        throw const AppException('Respon server tidak valid');
      }

      final productData = data['data'];
      if (productData == null) {
        _log.w('[ProductAdminDataSource] Response data["data"] is null');
        // Check if this is a direct product response (no wrapper)
        if (data is Map<String, dynamic> && data.containsKey('id')) {
          _log.d('[ProductAdminDataSource] Using direct response as product data');
          return ProductModel.fromJson(data);
        }
        throw const AppException('Data produk tidak ditemukan dalam respon');
      }

      return ProductModel.fromJson(productData as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e, st) {
      _log.e('[ProductAdminDataSource] DioException saat create product',
          error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Update existing product menggunakan multipart/form-data
  /// Gunakan POST dengan _method=PUT untuk kompatibilitas Laravel
  Future<ProductModel> updateProduct(int id, ProductRequestModel request) async {
    try {
      _log.i('[ProductAdminDataSource] Update product: $id');

      // Build form data dengan support cross-platform
      final formData = await _buildProductFormData(request, isCreate: false);

      // Gunakan POST dengan _method=PUT untuk kompatibilitas Laravel
      // Laravel tidak selalu menangani PUT dengan multipart/form-data dengan baik
      _log.d('[ProductAdminDataSource] Sending POST with _method=PUT to ${ApiConstants.adminProducts}/$id');

      final response = await _dioClient.dio.post(
        '${ApiConstants.adminProducts}/$id',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      _log.i('[ProductAdminDataSource] Product updated successfully: $id');
      _log.d('[ProductAdminDataSource] Response status: ${response.statusCode}');
      _log.d('[ProductAdminDataSource] Response data: ${response.data}');

      // Validate response structure
      final data = response.data;
      if (data == null) {
        _log.w('[ProductAdminDataSource] Response data is null');
        throw const AppException('Respon server tidak valid');
      }

      final productData = data['data'];
      if (productData == null) {
        _log.w('[ProductAdminDataSource] Response data["data"] is null');
        // Check if this is a direct product response (no wrapper)
        if (data is Map<String, dynamic> && data.containsKey('id')) {
          _log.d('[ProductAdminDataSource] Using direct response as product data');
          return ProductModel.fromJson(data);
        }
        throw const AppException('Data produk tidak ditemukan dalam respon');
      }

      return ProductModel.fromJson(productData as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e, st) {
      _log.e('[ProductAdminDataSource] DioException saat update product: $id',
          error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    try {
      _log.i('[ProductAdminDataSource] Delete product: $id');

      await _dioClient.dio.delete('${ApiConstants.adminProducts}/$id');

      _log.d('[ProductAdminDataSource] Product deleted successfully: $id');
    } catch (e, st) {
      _log.e('[ProductAdminDataSource] Failed to delete product: $id',
          error: e, stackTrace: st);
      throw ErrorHandler.handle(e);
    }
  }

  /// Build FormData dengan support cross-platform (mobile & web)
  ///
  /// Mobile: Menggunakan MultipartFile.fromFile() dengan File.path
  /// Web: Menggunakan MultipartFile.fromBytes() dengan Uint8List
  Future<FormData> _buildProductFormData(
    ProductRequestModel request, {
    required bool isCreate,
  }) async {
    final map = <String, dynamic>{
      'name': request.name,
      'description': request.description,
      'price': request.price,
      'stock': request.stock,
      'category_id': request.categoryId,
    };

    // Untuk update, gunakan _method=PUT agar Laravel dapat menangani dengan benar
    if (!isCreate) {
      map['_method'] = 'PUT';
    }

    // Handle image upload berdasarkan platform
    if (request.hasImage) {
      if (request.isWebImage) {
        // Flutter Web: gunakan bytes
        _log.d('[ProductAdminDataSource] Platform: Web');
        _log.d('[ProductAdminDataSource] Image bytes size: ${request.imageBytes?.length ?? 0} bytes');
        _log.d('[ProductAdminDataSource] Image filename: ${request.imageName ?? 'unknown'}');

        map['image'] = MultipartFile.fromBytes(
          request.imageBytes!,
          filename: request.imageName ?? 'upload.jpg',
        );
      } else if (request.isMobileImage) {
        // Mobile (Android/iOS): gunakan file path
        _log.d('[ProductAdminDataSource] Platform: Mobile (Android/iOS)');
        _log.d('[ProductAdminDataSource] Image file path: ${request.image?.path ?? 'unknown'}');

        final filePath = request.image?.path ?? '';
        final fileName = filePath.split('/').last;
        final fileSize = await _getFileSize(request.image);

        _log.d('[ProductAdminDataSource] Image filename: $fileName');
        _log.d('[ProductAdminDataSource] Image file size: $fileSize bytes');

        map['image'] = await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        );
      }
    } else {
      _log.d('[ProductAdminDataSource] No image to upload');
    }

    _log.d('[ProductAdminDataSource] FormData fields: ${map.keys.toList()}');

    return FormData.fromMap(map);
  }

  /// Get file size for mobile platforms
  Future<int> _getFileSize(dynamic file) async {
    try {
      if (file != null) {
        // For dart:io File - get path and check length
        final path = file.path as String?;
        if (path != null && path.isNotEmpty) {
          final ioFile = file as dynamic;
          return ioFile.lengthSync() as int? ?? 0;
        }
      }
      return 0;
    } catch (e) {
      _log.w('[ProductAdminDataSource] Could not get file size: $e');
      return 0;
    }
  }
}