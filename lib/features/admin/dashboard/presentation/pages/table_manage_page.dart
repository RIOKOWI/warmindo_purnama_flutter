import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/table_admin_provider.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/widgets/table_admin_tile.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/widgets/table_form_dialog.dart';

/// Fake data untuk skeleton loader
final _fakeTables = List.generate(
  12,
  (i) => TableModel(
    id: i + 1,
    tableNumber: 'MEJA ${(i + 1).toString().padLeft(2, '0')}',
    status: 'available',
  ),
);

class TableManagePage extends StatefulWidget {
  const TableManagePage({super.key});

  @override
  State<TableManagePage> createState() => _TableManagePageState();
}

class _TableManagePageState extends State<TableManagePage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableAdminProvider>().fetchTables(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm(BuildContext context, TableModel? table) async {
    final result = await showDialog<TableModel>(
      context: context,
      builder: (_) => TableFormDialog(table: table),
    );

    if (result != null && mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmDelete(BuildContext context, TableModel table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.dark, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error, width: 3),
                ),
                child: const Icon(Icons.warning, color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Hapus meja?', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                '${table.tableNumber} akan dihapus permanen.',
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
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: 'Hapus',
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await _doDelete(context, table);
    }
  }

  Future<void> _doDelete(BuildContext context, TableModel table) async {
    final provider = context.read<TableAdminProvider>();
    final success = await provider.deleteTable(table.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '${table.tableNumber} berhasil dihapus' : 'Gagal: ${provider.errorMessage}'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(title: 'KELOLA MEJA'),
      body: Consumer<TableAdminProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (provider.tables.isNotEmpty) _buildSummaryHeader(provider),
              Expanded(child: _buildBody(provider)),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: AppColors.dark, offset: Offset(5, 5), blurRadius: 0)],
        ),
        child: FloatingActionButton(
          onPressed: () => _openForm(context, null),
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(TableAdminProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SummaryChip('Tersedia', provider.totalAvailable, AppColors.success),
            const SizedBox(width: 8),
            _SummaryChip('Terisi', provider.totalOccupied, AppColors.error),
            const SizedBox(width: 8),
            _SummaryChip('Total', provider.tables.length, AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TableAdminProvider provider) {
    if (provider.errorMessage != null && provider.tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            NeoButtonSmall(label: 'Coba Lagi', icon: Icons.refresh, onPressed: () => provider.fetchTables(refresh: true)),
          ],
        ),
      );
    }

    

    final data = provider.isLoading && provider.tables.isEmpty ? _fakeTables : provider.tables;

    return RefreshIndicator(
      onRefresh: () => provider.fetchTables(refresh: true),
      color: AppColors.accent,
      child: Skeletonizer(
        enabled: provider.isLoading && provider.tables.isEmpty,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final table = data[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TableAdminTile(
                table: table,
                onEdit: () => _openForm(context, table),
                onDelete: () => _confirmDelete(context, table),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip(this.label, this.count, this.color);

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
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}