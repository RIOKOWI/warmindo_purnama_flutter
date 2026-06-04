import 'package:equatable/equatable.dart';

/// Model representing a restaurant table
class TableModel extends Equatable {
  final int id;
  final String tableNumber;
  final String status;

  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.status,
  });

  /// Check if this table is available
  bool get isAvailable => status == 'available';

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as int,
      tableNumber: json['table_number'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, tableNumber, status];
}
