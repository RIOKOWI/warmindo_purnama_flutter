import 'package:equatable/equatable.dart';

/// Model representing an item in an order
class OrderItemModel extends Equatable {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final int productPrice;
  final int subtotal;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      productPrice: json['product_price'] as int,
      subtotal: json['subtotal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'product_price': productPrice,
      'subtotal': subtotal,
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        quantity,
        productPrice,
        subtotal,
      ];
}
