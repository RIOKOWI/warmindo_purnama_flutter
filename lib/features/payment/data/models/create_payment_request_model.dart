import 'package:equatable/equatable.dart';

/// Request model for creating a payment
class CreatePaymentRequestModel extends Equatable {
  final String paymentMethod;

  const CreatePaymentRequestModel({
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
    };
  }

  @override
  List<Object?> get props => [paymentMethod];
}
