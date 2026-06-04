import 'package:equatable/equatable.dart';

/// Cart product model representing product data within a cart item
class CartProduct extends Equatable {
  final int id;
  final String name;
  final int price;
  final String imageUrl;
  final int stock;

  const CartProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        imageUrl: json['image_url'] as String? ?? '',
        stock: json['stock'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image_url': imageUrl,
        'stock': stock,
      };

  @override
  List<Object?> get props => [id, name, price, imageUrl, stock];
}

/// Cart item model representing an item in the shopping cart
class CartItem extends Equatable {
  final int cartItemId;
  final int quantity;
  final CartProduct product;

  const CartItem({
    required this.cartItemId,
    required this.quantity,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        cartItemId: json['cart_item_id'] as int,
        quantity: json['quantity'] as int,
        product: CartProduct.fromJson(json['product'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'cart_item_id': cartItemId,
        'quantity': quantity,
        'product': product.toJson(),
      };

  /// Subtotal price for this cart item
  int get subtotal => product.price * quantity;

  @override
  List<Object?> get props => [cartItemId, quantity, product];
}

/// Cart response model for GET /cart
class CartResponse extends Equatable {
  final List<CartItem> items;
  final int totalItems;

  const CartResponse({
    required this.items,
    required this.totalItems,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List;
    return CartResponse(
      items: itemsList.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalItems: json['total_items'] as int? ?? itemsList.length,
    );
  }

  @override
  List<Object?> get props => [items, totalItems];
}
