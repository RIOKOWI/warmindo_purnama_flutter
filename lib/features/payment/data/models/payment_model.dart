import 'package:equatable/equatable.dart';
import '../../../../core/constants/payment_constants.dart';

/// Model representing a payment
class PaymentModel extends Equatable {
  final int id;
  final int orderId;
  final String paymentMethod;
  final int amount;
  final int fee;
  final int totalPayment;
  final String? paymentNumber;
  final String status;
  final DateTime expiredAt;
  final DateTime? completedAt;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.fee,
    required this.totalPayment,
    this.paymentNumber,
    required this.status,
    required this.expiredAt,
    this.completedAt,
  });

  /// Getter: check if payment is completed
  bool get isCompleted => status == 'completed';

  /// Getter: check if payment is expired
  bool get isExpired =>
      status == 'expired' || DateTime.now().isAfter(expiredAt);

  /// Getter: check if payment is pending
  bool get isPending => status == 'pending';

  /// Getter: check if payment method is QRIS
  bool get isQris => paymentMethodFromString(paymentMethod).isQris;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      paymentMethod: json['payment_method'] as String,
      amount: json['amount'] as int,
      fee: json['fee'] as int,
      totalPayment: json['total_payment'] as int,
      paymentNumber: json['payment_number'] as String?,
      status: json['status'] as String,
      expiredAt: DateTime.parse(json['expired_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount': amount,
      'fee': fee,
      'total_payment': totalPayment,
      'payment_number': paymentNumber,
      'status': status,
      'expired_at': expiredAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        status,
        paymentNumber,
      ];
}
