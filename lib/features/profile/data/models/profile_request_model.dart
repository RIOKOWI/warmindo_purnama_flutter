import 'package:equatable/equatable.dart';

/// Request model untuk update profile
class UpdateProfileRequest extends Equatable {
  final String name;
  final String email;
  final String? phone;

  const UpdateProfileRequest({
    required this.name,
    required this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
      };

  @override
  List<Object?> get props => [name, email, phone];
}

/// Request model untuk update password
class UpdatePasswordRequest extends Equatable {
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  const UpdatePasswordRequest({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

  @override
  List<Object?> get props => [currentPassword, password, passwordConfirmation];
}
