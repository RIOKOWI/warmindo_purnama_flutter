import 'package:equatable/equatable.dart';

/// Model representing payment details
class PaymentDetailsModel extends Equatable {
  final int id;
  final int orderId;
  final String paymentMethod;
  final int amount;
  final int fee;
  final int totalPayment;
  final String? paymentNumber;
  final String status;
  final String? invoiceNumber;
  final int totalAmount;
  final String? qrCode;
  final DateTime? expiredAt;
  final DateTime? completedAt;

  const PaymentDetailsModel({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.fee,
    required this.totalPayment,
    this.paymentNumber,
    required this.status,
    this.invoiceNumber,
    required this.totalAmount,
    this.qrCode,
    this.expiredAt,
    this.completedAt,
  });

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>?;
    return PaymentDetailsModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      paymentMethod: json['payment_method'] as String,
      amount: json['amount'] as int,
      fee: json['fee'] as int,
      totalPayment: json['total_payment'] as int,
      paymentNumber: json['payment_number'] as String?,
      status: json['status'] as String,
      invoiceNumber: order?['invoice_number'] as String?,
      totalAmount: order?['total_amount'] as int? ?? 0,
      qrCode: json['payment_number'] as String?, // QRIS uses payment_number as QR code
      expiredAt: json['expired_at'] != null
          ? DateTime.parse(json['expired_at'] as String)
          : null,
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
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'qr_code': qrCode,
      'expired_at': expiredAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        paymentMethod,
        amount,
        fee,
        totalPayment,
        paymentNumber,
        status,
        invoiceNumber,
        totalAmount,
        qrCode,
        expiredAt,
        completedAt,
      ];
}
