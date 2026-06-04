import 'package:equatable/equatable.dart';

/// Request model for creating a new order
class CreateOrderRequestModel extends Equatable {
  final int? restaurantTableId;
  final int orderTypeId;
  final String? notes;

  const CreateOrderRequestModel({
    this.restaurantTableId,
    required this.orderTypeId,
    this.notes,
  });

  /// Convert to JSON, excluding null values as per API requirements
  Map<String, dynamic> toJson() {
    return {
      if (restaurantTableId != null) 'restaurant_table_id': restaurantTableId,
      'order_type_id': orderTypeId,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [restaurantTableId, orderTypeId, notes];
}
