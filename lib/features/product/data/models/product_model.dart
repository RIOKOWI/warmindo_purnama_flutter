import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'category_model.dart';

final _log = Logger();

/// Product model representing a menu item
class ProductModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String imageUrl;
  final CategoryModel category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse category first to handle nested structure
      final categoryJson = json['category'];
      if (categoryJson == null) {
        _log.w('[ProductModel] category is null in JSON: $json');
        throw const FormatException('Category is required');
      }

      return ProductModel(
        id: _parseInt(json['id'], 'id'),
        name: _parseString(json['name'], 'name'),
        description: _parseString(json['description'], 'description'),
        price: _parseInt(json['price'], 'price'),
        stock: _parseInt(json['stock'], 'stock'),
        imageUrl: _parseStringOrDefault(json['image_url'], 'image_url', ''),
        category: CategoryModel.fromJson(categoryJson as Map<String, dynamic>),
      );
    } catch (e, st) {
      _log.e('[ProductModel] Failed to parse product JSON', error: e, stackTrace: st);
      _log.d('[ProductModel] Raw JSON: $json');
      rethrow;
    }
  }

  static int _parseInt(dynamic value, String fieldName) {
    if (value == null) {
      throw FormatException('$fieldName is null');
    }
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    throw FormatException('$fieldName has invalid type: ${value.runtimeType}');
  }

  static String _parseString(dynamic value, String fieldName) {
    if (value == null) {
      throw FormatException('$fieldName is null');
    }
    return value.toString();
  }

  static String _parseStringOrDefault(dynamic value, String fieldName, String defaultValue) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'category': category.toJson(),
    };
  }

  /// Check if product is available (has stock)
  bool get isAvailable => stock > 0;

  @override
  List<Object?> get props => [id, name, description, price, stock, imageUrl, category];
}
