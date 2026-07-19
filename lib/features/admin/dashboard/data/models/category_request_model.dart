import 'package:equatable/equatable.dart';

/// Request model untuk create/update kategori
class CategoryRequestModel extends Equatable {
  const CategoryRequestModel({
    required this.name,
  });

  final String name;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  List<Object?> get props => [name];
}
