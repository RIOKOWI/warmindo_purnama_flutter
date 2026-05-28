import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/payment_provider.dart';

/// Payment page for completing order payment
class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPaymentDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentProvider>();
    final currencyFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: _buildBody(payment, currencyFormat),
    );
  }

  Widget _buildBody(PaymentProvider payment, NumberFormat currencyFormat) {
    if (payment.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (payment.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(payment.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => payment.loadPaymentDetails(widget.orderId),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (payment.paymentDetails == null) {
      return const Center(
        child: Text('Detail pembayaran tidak ditemukan'),
      );
    }

    final details = payment.paymentDetails!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Invoice',
                    value: details.invoiceNumber ?? '-',
                  ),
                  _InfoRow(
                    label: 'Total',
                    value: 'Rp ${currencyFormat.format(details.totalAmount)}',
                  ),
                  _InfoRow(
                    label: 'Status',
                    value: details.status.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodSelector(
                    selectedMethod: payment.selectedMethod,
                    onSelect: payment.selectPaymentMethod,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Subtotal',
                    value: 'Rp ${currencyFormat.format(details.totalAmount)}',
                  ),
                  _InfoRow(
                    label: 'Biaya Admin',
                    value: 'Rp ${currencyFormat.format(details.fee)}',
                  ),
                  const Divider(),
                  _InfoRow(
                    label: 'Total Pembayaran',
                    value:
                        'Rp ${currencyFormat.format(details.totalPayment)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),

          if (details.qrCode != null) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Scan QR Code untuk membayar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Image.network(
                      details.qrCode!,
                      width: 200,
                      height: 200,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.qr_code,
                        size: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bayar sebelum: ${_formatExpiry(details.expiredAt)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: payment.selectedMethod != null && !payment.isProcessing
                  ? () => payment.processPayment(widget.orderId)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: payment.isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Bayar Sekarang'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiry(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
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

class _PaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final ValueChanged<String> onSelect;

  const _PaymentMethodSelector({
    required this.selectedMethod,
    required this.onSelect,
  });

  static const _methods = [
    {'id': 'qris', 'name': 'QRIS', 'icon': Icons.qr_code},
    {'id': 'bca_va', 'name': 'BCA VA', 'icon': Icons.account_balance},
    {'id': 'bni_va', 'name': 'BNI VA', 'icon': Icons.account_balance},
    {'id': 'bri_va', 'name': 'BRI VA', 'icon': Icons.account_balance},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _methods.map((method) {
        final isSelected = selectedMethod == method['id'];
        return GestureDetector(
          onTap: () => onSelect(method['id'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  method['icon'] as IconData,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  method['name'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}