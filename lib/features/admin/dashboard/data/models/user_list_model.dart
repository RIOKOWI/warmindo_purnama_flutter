import 'package:equatable/equatable.dart';
import 'user_admin_model.dart';

/// Model untuk response paginated list user dari API
/// Response structure: data['data']['data'] dan data['data']['meta']
class UserListModel extends Equatable {
  final List<UserAdminModel> users;
  final int currentPage;
  final int lastPage;
  final int total;

  const UserListModel({
    required this.users,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  /// Getter: apakah ada halaman berikutnya
  bool get hasNextPage => currentPage < lastPage;

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    // Dua level data: json['data']['data'] dan json['data']['meta']
    final dataContainer = json['data'] as Map<String, dynamic>;
    final usersData = dataContainer['data'] as List<dynamic>;
    final metaData = dataContainer['meta'] as Map<String, dynamic>;

    return UserListModel(
      users: usersData
          .map((e) => UserAdminModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: metaData['current_page'] as int,
      lastPage: metaData['last_page'] as int,
      total: metaData['total'] as int,
    );
  }

  @override
  List<Object?> get props => [users, currentPage, lastPage, total];
}