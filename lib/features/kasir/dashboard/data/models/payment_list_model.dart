import 'package:equatable/equatable.dart';

/// Nested order model for payment list
class PaymentOrderModel extends Equatable {
  const PaymentOrderModel({
    required this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.status,
  });

  final int id;
  final String invoiceNumber;
  final int totalAmount;
  final String status;

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      totalAmount: json['total_amount'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, invoiceNumber, totalAmount, status];
}

/// Single payment item in the list
class PaymentListItemModel extends Equatable {
  const PaymentListItemModel({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.fee,
    required this.totalPayment,
    required this.paymentNumber,
    required this.status,
    required this.expiredAt,
    this.completedAt,
    required this.order,
  });

  final int id;
  final int orderId;
  final String paymentMethod;
  final int amount;
  final int fee;
  final int totalPayment;
  final String paymentNumber;
  final String status;
  final DateTime expiredAt;
  final DateTime? completedAt;
  final PaymentOrderModel order;

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isQris => paymentMethod == 'qris';
  bool get isVA => paymentMethod == 'bni_va' || paymentMethod == 'bri_va' || paymentMethod == 'mandiri_va';

  factory PaymentListItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentListItemModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      paymentMethod: json['payment_method'] as String,
      amount: json['amount'] as int,
      fee: json['fee'] as int,
      totalPayment: json['total_payment'] as int,
      paymentNumber: json['payment_number'] as String,
      status: json['status'] as String,
      expiredAt: DateTime.parse(json['expired_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      order: PaymentOrderModel.fromJson(json['order'] as Map<String, dynamic>),
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
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'order': order.toJson(),
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
        expiredAt,
        completedAt,
        order,
      ];
}

/// Wrapper model for paginated payment list
class PaymentListModel extends Equatable {
  const PaymentListModel({
    required this.payments,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<PaymentListItemModel> payments;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;

  factory PaymentListModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final paymentsList = data['data'] as List;
    final meta = data['meta'] as Map<String, dynamic>;

    return PaymentListModel(
      payments: paymentsList
          .map((e) => PaymentListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int,
      lastPage: meta['last_page'] as int,
      total: meta['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payments': payments.map((e) => e.toJson()).toList(),
      'current_page': currentPage,
      'last_page': lastPage,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [payments, currentPage, lastPage, total];
}
