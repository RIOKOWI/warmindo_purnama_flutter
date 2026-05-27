import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../repositories/product_repository.dart';

/// Implementation of ProductRepository using remote data source
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }

  @override
  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    // Filter by categoryId is done client-side as per feat.md documentation
    return await _remoteDataSource.getProducts();
  }
}