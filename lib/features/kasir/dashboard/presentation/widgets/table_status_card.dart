import 'package:flutter/material.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import '../../data/models/table_model.dart';

/// Widget card untuk menampilkan status meja
class TableStatusCard extends StatelessWidget {
  const TableStatusCard({
    super.key,
    required this.table,
    required this.onTap,
  });

  final TableModel table;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = table.isAvailable ? AppColors.success : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              table.isAvailable ? Icons.chair_outlined : Icons.chair,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              table.tableNumber.replaceAll('MEJA ', ''),
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Text(
                table.isAvailable ? 'Tersedia' : 'Terisi',
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}