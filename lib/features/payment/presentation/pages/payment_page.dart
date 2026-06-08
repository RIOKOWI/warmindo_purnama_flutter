import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/constants/payment_constants.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_card.dart';
import 'package:warmindo_purnama_flutter/features/payment/presentation/providers/payment_provider.dart';
import 'package:warmindo_purnama_flutter/features/payment/presentation/widgets/payment_method_selector.dart';
import 'package:warmindo_purnama_flutter/features/payment/presentation/widgets/qris_display_widget.dart';
import 'package:warmindo_purnama_flutter/features/payment/presentation/widgets/va_display_widget.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.orderId,
    this.totalAmount = 0,
  });

  final int orderId;
  final int totalAmount;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    // Set totalAmount from widget parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PaymentProvider>().totalAmount = widget.totalAmount;
      }
    });
  }

  @override
  void dispose() {
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

    return PopScope(
      canPop: !payment.hasPayment || payment.isCompleted || payment.isExpired,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const NeoAppBar(
          title: 'PEMBAYARAN',
          showBackButton: true,
        ),
        body: !payment.hasPayment
            ? const _PaymentMethodView()
            : payment.isCompleted
                ? _PaymentSuccessView(payment: payment.payment!)
                : payment.isExpired
                    ? const _PaymentExpiredView()
                    : _PaymentActiveView(payment: payment),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
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
              Text('Keluar dari halaman pembayaran?', style: AppTextStyles.headline),
              const SizedBox(height: 12),
              Text('Pembayaran yang sudah dibuat akan tetap aktif hingga expired.',
                  style: AppTextStyles.body),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'Tetap di sini',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: 'Keluar',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
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

class _PaymentMethodView extends StatelessWidget {
  const _PaymentMethodView();

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, payment, _) {
        final orderId = context.findAncestorStateOfType<_PaymentPageState>()?.widget.orderId ?? 0;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PILIH METODE PEMBAYARAN', style: AppTextStyles.title),
                    const SizedBox(height: 16),
                    PaymentMethodSelector(
                      selected: payment.selectedMethod,
                      onSelect: payment.selectMethod,
                      amount: payment.totalAmount,
                    ),
                    if (payment.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(payment.errorMessage!,
                                style: AppTextStyles.body.copyWith(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  border: Border(top: BorderSide(color: AppColors.dark, width: 3)),
                ),
                child: NeoButton(
                  label: 'BAYAR SEKARANG',
                  isLoading: payment.isCreating,
                  onPressed: () => payment.createPayment(orderId),
                  width: double.infinity,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PaymentActiveView extends StatelessWidget {
  const _PaymentActiveView({required this.payment});

  final PaymentProvider payment;

  @override
  Widget build(BuildContext context) {
    final p = payment.payment!;
    final currencyFormat = NumberFormat('#,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          NeoCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: AppTextStyles.body),
                    Text('Rp ${currencyFormat.format(p.amount)}',
                        style: AppTextStyles.body),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Biaya layanan', style: AppTextStyles.body),
                    Text('Rp ${currencyFormat.format(p.fee)}',
                        style: AppTextStyles.body),
                  ],
                ),
                Container(
                  height: 2,
                  color: AppColors.dark,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL BAYAR', style: AppTextStyles.title),
                    Text(
                      'Rp ${currencyFormat.format(p.totalPayment)}',
                      style: AppTextStyles.headline.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (p.isQris)
            QrisDisplayWidget(qrString: p.paymentNumber ?? '')
          else
            VaDisplayWidget(
              vaNumber: p.paymentNumber ?? '',
              bankName: paymentMethodFromString(p.paymentMethod).label,
            ),
          const SizedBox(height: 16),
          _CountdownWidget(remaining: payment.remainingTime),
          const SizedBox(height: 16),
          NeoButton(
            label: 'CEK STATUS PEMBAYARAN',
            icon: Icons.refresh,
            isLoading: payment.isPolling,
            onPressed: payment.refreshStatus,
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}

class _CountdownWidget extends StatelessWidget {
  const _CountdownWidget({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    if (remaining.inSeconds <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.error, width: 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_off, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Waktu pembayaran telah habis',
                style: AppTextStyles.title.copyWith(color: AppColors.error)),
          ],
        ),
      );
    }

    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final isUrgent = remaining.inMinutes < 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? AppColors.warning : AppColors.dark,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Text('Selesaikan pembayaran dalam',
              style: AppTextStyles.caption.copyWith(
                color: isUrgent ? AppColors.warning : AppColors.textLight,
              )),
          const SizedBox(height: 8),
          Text(
            '$minutes:$seconds',
            style: AppTextStyles.display.copyWith(
              color: isUrgent ? AppColors.warning : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSuccessView extends StatelessWidget {
  const _PaymentSuccessView({required this.payment});

  final dynamic payment;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.success, width: 4),
              ),
              child: const Icon(Icons.check_circle,
                  size: 64, color: AppColors.success),
            ),
            const SizedBox(height: 24),
            Text('Pembayaran Berhasil!', style: AppTextStyles.headline),
            const SizedBox(height: 16),
            Text('Invoice: ${payment.paymentNumber ?? 'N/A'}',
                style: AppTextStyles.body),
            const SizedBox(height: 8),
            Text(
              'Total: Rp ${currencyFormat.format(payment.totalPayment)}',
              style: AppTextStyles.headline.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 32),
            NeoButton(
              label: 'KEMBALI KE BERANDA',
              onPressed: () {
                // Pop sampai root (ke shell) - shell navbar akan muncul
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.warning, width: 4),
              ),
              child: const Icon(Icons.timer_off,
                  size: 64, color: AppColors.warning),
            ),
            const SizedBox(height: 24),
            Text('Waktu pembayaran habis', style: AppTextStyles.headline),
            const SizedBox(height: 16),
            Text('Silakan buat pesanan baru',
                style: AppTextStyles.body.copyWith(color: AppColors.textLight),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            NeoButton(
              label: 'KEMBALI KE BERANDA',
              onPressed: () {
                // Pop sampai root (ke shell) - shell navbar akan muncul
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}