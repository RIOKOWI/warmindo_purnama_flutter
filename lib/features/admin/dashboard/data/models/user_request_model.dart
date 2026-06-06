import 'package:equatable/equatable.dart';

/// Request model untuk membuat user baru
/// Include password karena create user butuh password
class CreateUserRequestModel extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String password;
  final String passwordConfirmation;

  const CreateUserRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  @override
  List<Object?> get props => [name, email, phone, role];
}

/// Request model untuk update user
/// TIDAK include password karena update user tidak mengubah password
class UpdateUserRequestModel extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String role;

  const UpdateUserRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [name, email, phone, role];
}
