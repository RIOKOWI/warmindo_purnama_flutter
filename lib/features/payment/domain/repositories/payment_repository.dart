import '../../data/models/payment_details_model.dart';
import '../../data/models/create_payment_request_model.dart';

/// Abstract repository interface for payment operations
abstract class PaymentRepository {
  /// Create payment for an order
  Future<PaymentDetailsModel> createPayment({
    required int orderId,
    required CreatePaymentRequestModel request,
  });

  /// Get payment details by ID
  Future<PaymentDetailsModel> getPaymentDetails(int paymentId);
}
