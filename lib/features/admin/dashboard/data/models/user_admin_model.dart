import 'package:equatable/equatable.dart';

/// Model untuk data user dari API admin
/// Field berbeda dengan UserModel di auth feature
class UserAdminModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? fcmToken;
  final String? emailVerifiedAt;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  const UserAdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.fcmToken,
    this.emailVerifiedAt,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Getter: apakah user sudah di-soft delete
  bool get isDeleted => deletedAt != null;

  /// Getter: apakah user aktif (tidak di-soft delete)
  bool get isActive => deletedAt == null;

  factory UserAdminModel.fromJson(Map<String, dynamic> json) {
    return UserAdminModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      fcmToken: json['fcm_token'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'fcm_token': fcmToken,
      'email_verified_at': emailVerifiedAt,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [id, email, role, deletedAt];
}
