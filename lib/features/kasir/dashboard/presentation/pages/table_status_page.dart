import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/providers/table_provider.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/widgets/table_status_card.dart';

class TableStatusPage extends StatefulWidget {
  const TableStatusPage({super.key});

  @override
  State<TableStatusPage> createState() => _TableStatusPageState();
}

class _TableStatusPageState extends State<TableStatusPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableProvider>().fetchTables();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TableProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(
        title: 'STATUS MEJA',
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(TableProvider provider) {
    if (provider.isLoading && provider.tables.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (provider.errorMessage != null && provider.tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error, width: 3),
              ),
              child: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(provider.errorMessage!, textAlign: TextAlign.center, style: AppTextStyles.body),
            const SizedBox(height: 16),
            NeoButtonSmall(
              label: 'Coba Lagi',
              icon: Icons.refresh,
              onPressed: () => provider.fetchTables(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchTables(),
      color: AppColors.accent,
      child: Column(
        children: [
          _SummaryBar(
            available: provider.availableTables.length,
            occupied: provider.occupiedTables.length,
            total: provider.tables.length,
          ),
          if (provider.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Text(provider.errorMessage!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: provider.tables.length,
              itemBuilder: (context, index) {
                final table = provider.tables[index];
                return TableStatusCard(
                  table: table,
                  onTap: () => _onTapTable(context, table),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onTapTable(BuildContext context, table) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.dark, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(table.tableNumber, style: AppTextStyles.headline),
              const SizedBox(height: 12),
              Text(
                table.isAvailable ? 'Tandai meja ini sebagai TERISI?' : 'Tandai meja ini sebagai TERSEDIA?',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'Batal',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: 'Ya',
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        final provider = context.read<TableProvider>();
                        final ok = await provider.toggleTableStatus(table.id);
                        if (!context.mounted) return;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage ?? 'Gagal update status'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.available, required this.occupied, required this.total});

  final int available;
  final int occupied;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _SummaryChip(label: 'Tersedia', count: available, color: AppColors.success),
          const SizedBox(width: 8),
          _SummaryChip(label: 'Terisi', count: occupied, color: AppColors.error),
          const Spacer(),
          Text('Total: $total meja', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count', style: AppTextStyles.title.copyWith(color: color)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}