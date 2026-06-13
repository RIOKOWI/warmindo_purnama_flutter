import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API constants loaded from environment variables
class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? '';

  static int get timeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // Auth endpoints
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String me = 'auth/me';

  // Profile endpoints
  static const String profile = 'profile';
  static const String fcmToken = 'profile/fcm-token';
  static const String profilePassword = 'profile/password';

  // Product endpoints
  static const String products = 'products';
  static const String categories = 'categories';

  // Admin Product endpoints
  static const String adminProducts = 'admin/products';
  static String adminProductDetail(int id) => 'admin/products/$id';

  // Admin Category endpoints
  static const String adminCategories = 'admin/categories';
  static String adminCategoryDetail(int id) => 'admin/categories/$id';

  // Admin User endpoints
  static const String adminUsers = 'admin/users';
  static String adminUserDetail(int id) => 'admin/users/$id';
  static String adminUserRestore(int id) => 'admin/users/$id/restore';

  // Cart endpoints
  static const String cart = 'cart';
  static String cartItem(int cartItemId) => 'cart/$cartItemId';

  // Order endpoints
  static const String orders = 'orders';
  static String orderDetail(int orderId) => 'orders/$orderId';
  static String orderCancel(int orderId) => 'orders/$orderId/cancel';
  static String orderPayment(int orderId) => 'orders/$orderId/payment';

  // Payment endpoints
  static const String payments = 'payments';
  static String paymentDetails(int paymentId) => 'payments/$paymentId';

  // Checkout endpoints
  static const String orderTypes = 'order-types';
  static const String tablesAvailable = 'tables/available';

  // Table endpoints
  static const String tables = 'tables';
  static String tableStatus(int tableId) => 'tables/$tableId/status';

  // Admin Table endpoints
  static const String adminTables = 'admin/tables';
  static String adminTableDetail(int id) => 'admin/tables/$id';
}