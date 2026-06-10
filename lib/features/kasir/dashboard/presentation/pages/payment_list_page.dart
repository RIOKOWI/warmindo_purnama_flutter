import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/constants/payment_constants.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/payment_list_model.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/providers/payment_list_provider.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/widgets/payment_list_tile.dart';

/// Fake data untuk skeleton loader
final _fakePayments = List.generate(7, (i) => PaymentListItemModel(
  id: i,
  orderId: i,
  amount: 0,
  fee: 0,
  totalPayment: 0,
  paymentNumber: 'PAY-$i',
  paymentMethod: 'qris',
  status: 'pending',
  expiredAt: DateTime(2024, 1, 1),
  order: PaymentOrderModel(
    id: i,
    invoiceNumber: 'INV-0000',
    totalAmount: 0,
    status: 'pending',
  ),
));

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentListProvider>().fetchPayments(refresh: true);
    });

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
      backgroundColor: AppColors.background,
      appBar: const NeoAppBar(title: 'PEMBAYARAN'),
      body: Column(
        children: [
          if (provider.payments.isNotEmpty && !provider.isFetchingAll) _SummaryHeader(provider: provider),
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
    // Tampilkan loading shimmer saat fetch semua halaman
    if (provider.isFetchingAll) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Skeletonizer(
              enabled: true,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dark, width: 3),
                ),
                child: const Icon(Icons.payment, size: 48, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 16),
            Text('Memuat semua data...', style: AppTextStyles.body),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && provider.payments.isEmpty) {
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
            Text(provider.errorMessage!,
                textAlign: TextAlign.center, style: AppTextStyles.body),
            const SizedBox(height: 16),
            NeoButtonSmall(
              label: 'Coba Lagi',
              icon: Icons.refresh,
              onPressed: () => provider.fetchPayments(refresh: true),
            ),
          ],
        ),
      );
    }


    // Tampilkan data atau skeleton berdasarkan state loading
    final payments = provider.isLoading && provider.payments.isEmpty
        ? _fakePayments
        : provider.payments;

    return RefreshIndicator(
      onRefresh: () => provider.fetchPayments(refresh: true),
      color: AppColors.accent,
      child: Skeletonizer(
        enabled: provider.isLoading && provider.payments.isEmpty,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: payments.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == payments.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              );
            }

            final payment = payments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PaymentListTile(
                payment: payment,
                onTap: () => _showPaymentDetail(context, payment),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPaymentDetail(BuildContext context, PaymentListItemModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentDetailSheet(payment: payment),
    );
  }
}

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
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Menunggu',
            value: '${provider.totalPending}',
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Total',
            value: 'Rp ${_formatNumber(provider.grandTotal)}',
            color: AppColors.accent,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.title.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.activeFilter, required this.onFilter});

  final String? activeFilter;
  final void Function(String?) onFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(label: 'Semua', isSelected: activeFilter == null, onTap: () => onFilter(null)),
          const SizedBox(width: 8),
          _FilterChip(label: 'Lunas', isSelected: activeFilter == 'completed', onTap: () => onFilter('completed')),
          const SizedBox(width: 8),
          _FilterChip(label: 'Menunggu', isSelected: activeFilter == 'pending', onTap: () => onFilter('pending')),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dark, width: 2),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? Colors.white : AppColors.text,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PaymentDetailSheet extends StatelessWidget {
  const _PaymentDetailSheet({required this.payment});

  final PaymentListItemModel payment;

  @override
  Widget build(BuildContext context) {
    final methodLabel = paymentMethodFromString(payment.paymentMethod).label;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.dark, width: 3)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(payment.order.invoiceNumber, style: AppTextStyles.headline),
            const SizedBox(height: 8),
            _PaymentStatusBadge(status: payment.status),
            Container(height: 2, color: AppColors.dark, margin: const EdgeInsets.symmetric(vertical: 16)),
            _DetailRow(label: 'Metode', value: methodLabel),
            _DetailRow(label: 'Subtotal', value: 'Rp ${_formatNumber(payment.amount)}'),
            _DetailRow(label: 'Biaya layanan', value: 'Rp ${_formatNumber(payment.fee)}'),
            _DetailRow(label: 'Total Bayar', value: 'Rp ${_formatNumber(payment.totalPayment)}', isBold: true),
            Container(height: 2, color: AppColors.dark, margin: const EdgeInsets.symmetric(vertical: 12)),
            _DetailRow(label: 'Status Order', value: payment.order.status),
            if (payment.completedAt != null) _DetailRow(label: 'Waktu Bayar', value: _formatDateTime(payment.completedAt!)),
            _DetailRow(label: 'Kadaluarsa', value: _formatDateTime(payment.expiredAt)),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) => number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  String _formatDateTime(DateTime dt) => '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.isBold = false});

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textLight)),
          const Spacer(),
          Text(value, style: isBold ? AppTextStyles.title : AppTextStyles.body),
        ],
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'completed' => ('Lunas', AppColors.success),
      'pending' => ('Menunggu', AppColors.warning),
      _ => (status, AppColors.textLight),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}