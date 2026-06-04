import 'package:equatable/equatable.dart';

/// Model untuk data meja restoran
class TableModel extends Equatable {
  final int id;
  final String tableNumber;
  final String status;

  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.status,
  });

  /// Dari JSON API
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as int,
      tableNumber: json['table_number'] as String,
      status: json['status'] as String,
    );
  }

  /// Ke JSON untuk request body
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'status': status,
    };
  }

  /// Apakah meja ini tersedia
  bool get isAvailable => status == 'available';

  /// Apakah meja ini terisi
  bool get isOccupied => status == 'occupied';

  /// Copy dengan status baru (untuk optimistic update)
  TableModel copyWith({String? status}) {
    return TableModel(
      id: id,
      tableNumber: tableNumber,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, tableNumber, status];
}