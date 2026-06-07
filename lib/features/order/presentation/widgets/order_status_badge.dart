import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';

/// Neo Brutalism badge widget to display order status with color coding
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String label, Color color) _getStatusConfig() {
    switch (status) {
      case 'pending':
        return ('Menunggu Pembayaran', AppColors.warning);
      case 'paid':
        return ('Dibayar', AppColors.success);
      case 'cancelled':
        return ('Dibatalkan', AppColors.error);
      case 'completed':
        return ('Selesai', AppColors.info);
      default:
        return (status, AppColors.textLight);
    }
  }
}