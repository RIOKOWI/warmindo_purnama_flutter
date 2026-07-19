import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/widgets/table_status_card.dart';

/// Fake data for skeleton loading
final fakeTables = List.generate(
  12,
  (i) => TableModel(
    id: i + 1,
    tableNumber: 'M${i + 1}',
    status: 'available',
  ),
);

/// Skeletonizer widget for table grid
class TableStatusSkeletonizer extends StatelessWidget {
  const TableStatusSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 450 ? 3 : 4;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.82,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: fakeTables.length,
            itemBuilder: (context, index) {
              final table = fakeTables[index];
              return TableStatusCard(
                table: table,
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}