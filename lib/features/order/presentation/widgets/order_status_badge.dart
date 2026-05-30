import 'package:flutter/material.dart';

/// Badge widget to display order status with color coding
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  (String label, Color color) _getStatusConfig() {
    switch (status) {
      case 'pending':
        return ('Menunggu Pembayaran', Colors.orange);
      case 'paid':
        return ('Dibayar', Colors.green);
      case 'cancelled':
        return ('Dibatalkan', Colors.red);
      case 'completed':
        return ('Selesai', Colors.blue);
      default:
        return (status, Colors.grey);
    }
  }
}