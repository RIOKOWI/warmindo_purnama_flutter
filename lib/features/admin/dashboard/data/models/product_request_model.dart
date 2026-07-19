import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Request model untuk create/update produk
/// Mendukung upload gambar untuk mobile (File) dan web (bytes)
class ProductRequestModel extends Equatable {
  const ProductRequestModel({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    // Mobile: menggunakan File dari dart:io
    this.image,
    // Web: menggunakan bytes dan filename
    this.imageBytes,
    this.imageName,
  });

  final String name;
  final String description;
  final int price;
  final int stock;
  final int categoryId;

  /// Mobile file image (dart:io File)
  final dynamic image;

  /// Web image bytes (from file_picker)
  final Uint8List? imageBytes;

  /// Web image filename
  final String? imageName;

  /// Check if has image (from mobile or web)
  bool get hasImage => image != null || imageBytes != null;

  /// Check if image is from web
  bool get isWebImage => imageBytes != null && image == null;

  /// Check if image is from mobile
  bool get isMobileImage => image != null;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
    };
  }

  /// Create copy with new values
  ProductRequestModel copyWith({
    String? name,
    String? description,
    int? price,
    int? stock,
    int? categoryId,
    dynamic image,
    Uint8List? imageBytes,
    String? imageName,
  }) {
    return ProductRequestModel(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
      imageBytes: imageBytes ?? this.imageBytes,
      imageName: imageName ?? this.imageName,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        price,
        stock,
        categoryId,
        image,
        imageBytes,
        imageName,
      ];
}