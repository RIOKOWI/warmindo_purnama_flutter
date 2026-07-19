import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/constants/payment_constants.dart';
import '../../data/models/payment_list_model.dart';

/// Widget tile untuk menampilkan item payment di list
class PaymentListTile extends StatelessWidget {
  const PaymentListTile({
    super.key,
    required this.payment,
    this.onTap,
  });

  final PaymentListItemModel payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        isThreeLine: true,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              payment.isQris ? Colors.blue.shade100 : Colors.purple.shade100,
          child: Icon(
            payment.isQris ? Icons.qr_code : Icons.account_balance,
            color: payment.isQris ? Colors.blue : Colors.purple,
            size: 24,
          ),
        ),
        title: Text(
          payment.order.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatMethod(payment.paymentMethod)),
            Text(
              'Rp ${_formatNumber(payment.totalPayment)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _PaymentStatusBadge(status: payment.status),
            const SizedBox(height: 4),
            Text(
              _formatDate(payment.completedAt ?? payment.expiredAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format payment method label
  String _formatMethod(String method) {
    final pm = paymentMethodFromString(method);
    return pm.label;
  }

  /// Format date to 'DD/MM HH:MM'
  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  /// Format number with thousand separator
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}

/// Badge widget untuk status payment
class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'completed' => ('Lunas', Colors.green),
      'pending' => ('Menunggu', Colors.orange),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}