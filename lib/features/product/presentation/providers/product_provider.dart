import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

/// Product provider for state management
class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository);

  final ProductRepository _repository;
  final Logger _log = Logger();

  // State
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  int? _selectedCategoryId; // null = tampilkan semua
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _selectedCategoryId == null
      ? _products
      : _products.where((p) => p.category.id == _selectedCategoryId).toList();
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize data - fetch categories and products in parallel
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch categories dan products secara paralel
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getProducts(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductModel>;

      _log.i('[ProductProvider] Loaded ${_categories.length} categories and ${_products.length} products');
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Gagal memuat data';
      _log.e('[ProductProvider] DioException', error: e);
    } catch (e, st) {
      _errorMessage = 'Gagal memuat data';
      _log.e('[ProductProvider] Unknown error', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a category for filtering (null = show all)
  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _log.d('[ProductProvider] Selected category: $categoryId');
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await init();
  }
}