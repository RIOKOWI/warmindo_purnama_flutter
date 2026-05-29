import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Widget for displaying QRIS QR code
class QrisDisplayWidget extends StatelessWidget {
  const QrisDisplayWidget({
    super.key,
    required this.qrString,
  });

  final String qrString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Scan QR Code untuk membayar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data: qrString,
              version: QrVersions.auto,
              size: 240,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              errorStateBuilder: (context, error) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 8),
                      Text('Gagal membuat QR Code'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Gunakan aplikasi e-wallet atau mobile banking apapun',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}