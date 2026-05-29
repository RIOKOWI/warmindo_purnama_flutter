import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/qris_display_widget.dart';
import '../widgets/va_display_widget.dart';

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
    // Initialize provider with order ID if needed
  }

  @override
  void dispose() {
    // Cleanup timers when page is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<PaymentProvider>().cleanup();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentProvider>();
    final currencyFormat = NumberFormat('#,###');

    return PopScope(
      canPop: !payment.hasPayment || payment.isCompleted || payment.isExpired,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran'),
          automaticallyImplyLeading: false,
        ),
        body: !payment.hasPayment
            ? _PaymentMethodView(
                orderId: widget.orderId,
                currencyFormat: currencyFormat,
              )
            : payment.isCompleted
                ? _PaymentSuccessView(
                    payment: payment.payment!,
                    currencyFormat: currencyFormat,
                  )
                : payment.isExpired
                    ? const _PaymentExpiredView()
                    : _PaymentActiveView(
                        payment: payment,
                        currencyFormat: currencyFormat,
                      ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari halaman pembayaran?'),
        content: const Text(
          'Pembayaran yang sudah dibuat akan tetap aktif hingga expired.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tetap di sini'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Pop page
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

/// View for selecting payment method
class _PaymentMethodView extends StatelessWidget {
  const _PaymentMethodView({
    required this.orderId,
    required this.currencyFormat,
  });

  final int orderId;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentProvider>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                PaymentMethodSelector(
                  selected: payment.selectedMethod,
                  onSelect: payment.selectMethod,
                ),
                if (payment.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    payment.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: payment.isCreating
                    ? null
                    : () => payment.createPayment(orderId),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: payment.isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Bayar Sekarang'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// View for active payment with countdown
class _PaymentActiveView extends StatelessWidget {
  const _PaymentActiveView({
    required this.payment,
    required this.currencyFormat,
  });

  final PaymentProvider payment;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final p = payment.payment!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Billing info
          _BillingInfo(payment: p, currencyFormat: currencyFormat),
          const Divider(height: 32),
          // Payment display (QRIS or VA)
          if (p.isQris)
            QrisDisplayWidget(qrString: p.paymentNumber ?? '')
          else
            VaDisplayWidget(
              vaNumber: p.paymentNumber ?? '',
              bankName: paymentMethodFromString(p.paymentMethod).label,
            ),
          const SizedBox(height: 24),
          // Countdown widget
          _CountdownWidget(remaining: payment.remainingTime),
          const SizedBox(height: 16),
          // Refresh status button
          Center(
            child: OutlinedButton.icon(
              onPressed: payment.isPolling ? null : payment.refreshStatus,
              icon: payment.isPolling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Cek Status Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Billing info widget
class _BillingInfo extends StatelessWidget {
  const _BillingInfo({
    required this.payment,
    required this.currencyFormat,
  });

  final dynamic payment;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal'),
            Text('Rp ${currencyFormat.format(payment.amount)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Biaya layanan'),
            Text('Rp ${currencyFormat.format(payment.fee)}'),
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Bayar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Rp ${currencyFormat.format(payment.totalPayment)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

/// Countdown widget
class _CountdownWidget extends StatelessWidget {
  const _CountdownWidget({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    if (remaining.inSeconds <= 0) {
      return const Center(
        child: Text(
          'Waktu pembayaran telah habis',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final isUrgent = remaining.inMinutes < 5;

    return Center(
      child: Column(
        children: [
          Text(
            'Selesaikan pembayaran dalam',
            style: TextStyle(
              color: isUrgent ? Colors.red : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isUrgent ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// Success view
class _PaymentSuccessView extends StatelessWidget {
  const _PaymentSuccessView({
    required this.payment,
    required this.currencyFormat,
  });

  final dynamic payment;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Invoice: ${payment.paymentNumber ?? 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: Rp ${currencyFormat.format(payment.totalPayment)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.dashboard,
                  (route) => false,
                );
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expired view
class _PaymentExpiredView extends StatelessWidget {
  const _PaymentExpiredView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.timer_off,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Waktu pembayaran habis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan buat pesanan baru',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.dashboard,
                  (route) => false,
                );
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}