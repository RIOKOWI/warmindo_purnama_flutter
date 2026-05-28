import 'package:equatable/equatable.dart';
import 'order_item_model.dart';

/// Model representing a complete order
class OrderModel extends Equatable {
  final int id;
  final String invoiceNumber;
  final int userId;
  final int? restaurantTableId;
  final int orderTypeId;
  final int subtotal;
  final int totalAmount;
  final String status;
  final String? notes;
  final List<OrderItemModel> orderItems;

  const OrderModel({
    required this.id,
    required this.invoiceNumber,
    required this.userId,
    this.restaurantTableId,
    required this.orderTypeId,
    required this.subtotal,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderItemsJson = json['order_items'] as List<dynamic>?;
    final orderItems = orderItemsJson != null
        ? orderItemsJson
            .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
            .toList()
        : <OrderItemModel>[];

    return OrderModel(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      userId: json['user_id'] as int,
      restaurantTableId: json['restaurant_table_id'] as int?,
      orderTypeId: json['order_type_id'] as int,
      subtotal: json['subtotal'] as int,
      totalAmount: json['total_amount'] as int,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      orderItems: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'user_id': userId,
      'restaurant_table_id': restaurantTableId,
      'order_type_id': orderTypeId,
      'subtotal': subtotal,
      'total_amount': totalAmount,
      'status': status,
      'notes': notes,
      'order_items': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        userId,
        restaurantTableId,
        orderTypeId,
        subtotal,
        totalAmount,
        status,
        notes,
        orderItems,
      ];
}
