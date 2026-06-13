/// Model request untuk create/update table
class TableRequestModel {
  final String tableNumber;
  final String status;

  const TableRequestModel({
    required this.tableNumber,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'table_number': tableNumber,
        'status': status,
      };
}