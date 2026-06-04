import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/table_provider.dart';
import '../widgets/table_status_card.dart';

/// Halaman status meja untuk kasir/admin
class TableStatusPage extends StatefulWidget {
  const TableStatusPage({super.key});

  @override
  State<TableStatusPage> createState() => _TableStatusPageState();
}

class _TableStatusPageState extends State<TableStatusPage> {
  @override
  void initState() {
    super.initState();
    // Fetch tables saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableProvider>().fetchTables();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TableProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Meja'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchTables(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(TableProvider provider) {
    // Loading state - show loading indicator
    if (provider.isLoading && provider.tables.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange,
        ),
      );
    }

    // Error state - show error message
    if (provider.errorMessage != null && provider.tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.fetchTables(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Normal state with data
    return RefreshIndicator(
      onRefresh: () => provider.fetchTables(),
      color: Colors.deepOrange,
      child: Column(
        children: [
          // Summary bar
          _SummaryBar(
            available: provider.availableTables.length,
            occupied: provider.occupiedTables.length,
            total: provider.tables.length,
          ),
          // Error message thin bar (saat update gagal)
          if (provider.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.red.shade100,
              child: Text(
                provider.errorMessage!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          // Grid meja
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
      builder: (dialogContext) => AlertDialog(
        title: Text(table.tableNumber),
        content: Text(
          table.isAvailable
              ? 'Tandai meja ini sebagai TERISI?'
              : 'Tandai meja ini sebagai TERSEDIA?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup dialog dulu
              final provider = context.read<TableProvider>();
              final ok = await provider.toggleTableStatus(table.id);
              if (!context.mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Gagal update status'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }
}

/// Widget ringkasan statistik meja
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.available,
    required this.occupied,
    required this.total,
  });

  final int available;
  final int occupied;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _SummaryChip(
            label: 'Tersedia',
            count: available,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _SummaryChip(
            label: 'Terisi',
            count: occupied,
            color: Colors.red,
          ),
          const Spacer(),
          Text(
            'Total: $total meja',
 style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}