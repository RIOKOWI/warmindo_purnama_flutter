import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: table.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon kursi
            Icon(
              table.isAvailable ? Icons.chair_outlined : Icons.chair,
              size: 32,
              color: table.isAvailable ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            // Nomor meja
            Text(
              table.tableNumber.replaceAll('MEJA ', ''),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            // Badge status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (table.isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                table.isAvailable ? 'Tersedia' : 'Terisi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: table.isAvailable ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}