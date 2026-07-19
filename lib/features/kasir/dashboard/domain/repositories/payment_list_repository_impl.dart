import 'package:logger/logger.dart';
import '../../data/datasources/payment_list_datasource.dart';
import '../../data/models/payment_list_model.dart';
import 'payment_list_repository.dart';

/// Implementation dari PaymentListRepository
class PaymentListRepositoryImpl implements PaymentListRepository {
  PaymentListRepositoryImpl({required PaymentListDataSource dataSource})
      : _dataSource = dataSource;

  final PaymentListDataSource _dataSource;
  final Logger _log = Logger();

  @override
  Future<PaymentListModel> getPayments({
    int page = 1,
    String? statusFilter,
  }) async {
    try {
      return await _dataSource.getPayments(
        page: page,
        statusFilter: statusFilter,
      );
    } catch (e, st) {
      _log.e('[PaymentListRepositoryImpl] Failed to get payments',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}