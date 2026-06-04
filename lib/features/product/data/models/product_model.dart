import 'package:equatable/equatable.dart';
import 'category_model.dart';

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
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String? ?? '',
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
    );
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
