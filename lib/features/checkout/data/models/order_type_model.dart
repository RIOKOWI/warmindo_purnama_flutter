import 'package:equatable/equatable.dart';

/// Model representing an order type (e.g., dine_in, take_away)
class OrderTypeModel extends Equatable {
  final int id;
  final String name;

  const OrderTypeModel({
    required this.id,
    required this.name,
  });

  /// Check if this is a dine-in order type
  bool get isDineIn => name == 'dine_in';

  factory OrderTypeModel.fromJson(Map<String, dynamic> json) {
    return OrderTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
