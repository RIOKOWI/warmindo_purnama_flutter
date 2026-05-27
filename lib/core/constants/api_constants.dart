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

  // Product endpoints
  static const String products = 'products';
  static const String categories = 'categories';

  // Cart endpoints
  static const String cart = 'cart';
  static String cartItem(int cartItemId) => 'cart/$cartItemId';
}