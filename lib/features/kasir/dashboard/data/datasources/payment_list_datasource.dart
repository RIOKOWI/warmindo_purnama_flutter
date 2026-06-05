import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:warmindo_purnama_flutter/core/constants/api_constants.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import '../models/payment_list_model.dart';

/// Remote data source untuk payment list API calls
class PaymentListDataSource {
  PaymentListDataSource(this._dioClient);

  final DioClient _dioClient;
  final Logger _log = Logger();

  /// Ambil semua payment dengan pagination dan filter
  Future<PaymentListModel> getPayments({
    int page = 1,
    String? statusFilter,
  }) async {
    try {
      _log.i(
          '[PaymentListDataSource] Fetch payments page: $page, filter: $statusFilter');

      final queryParams = <String, dynamic>{'page': page};
      if (statusFilter != null) {
        queryParams['status'] = statusFilter;
      }

      final response = await _dioClient.dio.get(
        ApiConstants.payments,
        queryParameters: queryParams,
      );

      _log.d('[PaymentListDataSource] Payments fetched successfully');

      return PaymentListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      _log.e('[PaymentListDataSource] Failed to fetch payments',
          error: e, stackTrace: st);
      final message = e.response?.data['message'] as String?;
      throw Exception(message ?? 'Gagal memuat data pembayaran');
    } catch (e, st) {
      _log.e('[PaymentListDataSource] Unknown error', error: e, stackTrace: st);
      rethrow;
    }
  }
}