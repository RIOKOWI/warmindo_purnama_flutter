import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/constants/payment_constants.dart';
import '../../data/models/payment_list_model.dart';
import '../providers/payment_list_provider.dart';
import '../widgets/payment_list_tile.dart';

/// Halaman list payment untuk kasir/admin
class PaymentListPage extends StatefulWidget {
  const PaymentListPage({super.key});

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Fetch payments on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentListProvider>().fetchPayments(refresh: true);
    });

    // Infinite scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PaymentListProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (provider.payments.isNotEmpty) _SummaryHeader(provider: provider),
          _FilterBar(
            activeFilter: provider.activeFilter,
            onFilter: provider.applyFilter,
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(PaymentListProvider provider) {
    // Loading state
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepOrange),
      );
    }

    // Error state
    if (provider.errorMessage != null && provider.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.fetchPayments(refresh: true),
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

    // Empty state
    if (provider.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              provider.activeFilter != null
                  ? 'Tidak ada payment dengan filter tersebut'
                  : 'Belum ada data pembayaran',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Normal state with data
    return RefreshIndicator(
      onRefresh: () => provider.fetchPayments(refresh: true),
      color: Colors.deepOrange,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: provider.payments.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at the end
          if (index == provider.payments.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            );
          }

          final payment = provider.payments[index];
          return PaymentListTile(
            payment: payment,
            onTap: () => _showPaymentDetail(context, payment),
          );
        },
      ),
    );
  }

  void _showPaymentDetail(BuildContext context, PaymentListItemModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PaymentDetailSheet(payment: payment),
    );
  }
}

/// Summary header widget showing totals
class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.provider});

  final PaymentListProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(
            label: 'Lunas',
            value: '${provider.totalCompleted}',
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Menunggu',
            value: '${provider.totalPending}',
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Total',
            value: 'Rp ${_formatNumber(provider.grandTotal)}',
            color: Colors.blue,
            flex: 2,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.flex = 1,
  });

  final String label;
  final String value;
  final Color color;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter bar widget
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.activeFilter,
    required this.onFilter,
  });

  final String? activeFilter;
  final void Function(String?) onFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: activeFilter == null,
            onSelected: (_) => onFilter(null),
            selectedColor: Colors.deepOrange.shade100,
            checkmarkColor: Colors.deepOrange,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Lunas'),
            selected: activeFilter == 'completed',
            onSelected: (_) => onFilter('completed'),
            selectedColor: Colors.green.shade100,
            checkmarkColor: Colors.green,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Menunggu'),
            selected: activeFilter == 'pending',
            onSelected: (_) => onFilter('pending'),
            selectedColor: Colors.orange.shade100,
            checkmarkColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

/// Payment detail bottom sheet
class _PaymentDetailSheet extends StatelessWidget {
  const _PaymentDetailSheet({required this.payment});

  final PaymentListItemModel payment;

  @override
  Widget build(BuildContext context) {
    final methodLabel = paymentMethodFromString(payment.paymentMethod).label;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(20),
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Invoice number
          Text(
            payment.order.invoiceNumber,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Status badge
          _PaymentStatusBadge(status: payment.status),
          const Divider(height: 32),

          // Method
          _DetailRow(label: 'Metode', value: methodLabel),
          _DetailRow(
            label: 'Subtotal',
            value: 'Rp ${_formatNumber(payment.amount)}',
          ),
          _DetailRow(
            label: 'Biaya layanan',
            value: 'Rp ${_formatNumber(payment.fee)}',
          ),
          _DetailRow(
            label: 'Total Bayar',
            value: 'Rp ${_formatNumber(payment.totalPayment)}',
            isBold: true,
          ),
          const Divider(height: 24),

          // Order status
          _DetailRow(label: 'Status Order', value: payment.order.status),
          if (payment.completedAt != null)
            _DetailRow(
              label: 'Waktu Bayar',
              value: _formatDateTime(payment.completedAt!),
            ),
          _DetailRow(
            label: 'Kadaluarsa',
            value: _formatDateTime(payment.expiredAt),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge widget (reused in detail sheet)
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