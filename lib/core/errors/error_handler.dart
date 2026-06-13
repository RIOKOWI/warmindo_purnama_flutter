import 'package:dio/dio.dart';
import 'app_exception.dart';

/// Handler global untuk mengkonversi berbagai jenis error
/// menjadi [AppException] dengan pesan yang ramah untuk user.
class ErrorHandler {
  ErrorHandler._();

  /// Konversi error apapun menjadi [AppException].
  ///
  /// Mendukung:
  /// - [DioException] dengan berbagai tipe koneksi & status code HTTP
  /// - [AppException] (diteruskan langsung)
  /// - Error lainnya (fallback ke pesan generik)
  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    return const AppException('Terjadi kesalahan. Silakan coba lagi.');
  }

  static AppException _handleDioException(DioException e) {
    // Network / connection errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const AppException('Koneksi timeout, silakan coba lagi.');
      case DioExceptionType.receiveTimeout:
        return const AppException('Server terlalu lama merespon.');
      case DioExceptionType.connectionError:
        return const AppException('Tidak ada koneksi internet.');
      default:
        break;
    }

    // HTTP status code errors
    final statusCode = e.response?.statusCode;
    final responseMessage = _extractMessage(e.response?.data);

    switch (statusCode) {
      case 400:
        return AppException(responseMessage ?? 'Data tidak valid');
      case 401:
        return AppException(responseMessage ?? 'Silakan login kembali');
      case 403:
        return AppException(responseMessage ?? 'Anda tidak memiliki akses');
      case 404:
        return AppException(responseMessage ?? 'Data tidak ditemukan');
      case 422:
        return AppException(responseMessage ?? 'Validasi gagal');
      case 500:
        return AppException(responseMessage ?? 'Server sedang bermasalah');
      default:
        return AppException(
          responseMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
        );
    }
  }

  /// Ekstrak field `message` dari response body jika ada.
  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
    return null;
  }
}
