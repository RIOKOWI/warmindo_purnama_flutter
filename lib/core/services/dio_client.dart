import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import 'secure_storage.dart';

/// Dio client with interceptors for logging and token injection.
class DioClient {
  DioClient(this._secureStorage);

  final SecureStorage _secureStorage;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  Dio? _dio;

  /// Get or create Dio instance
  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.timeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.timeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log request
          _logger.d('🌐 REQUEST[${options.method}] => PATH: ${options.path}');

          // Inject Bearer token from SecureStorage
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            _logger.d('🔑 Token injected for request');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            '❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            error: error,
          );

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            _logger.w('🔓 Token expired or invalid, clearing storage...');
            _secureStorage.clearAll();
          }

          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}