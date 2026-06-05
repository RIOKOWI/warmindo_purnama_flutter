import '../../data/models/payment_list_model.dart';

/// Abstract repository untuk payment list operations
abstract class PaymentListRepository {
  /// Ambil semua payment dengan pagination
  Future<PaymentListModel> getPayments({
    int page = 1,
    String? statusFilter,
  });
}