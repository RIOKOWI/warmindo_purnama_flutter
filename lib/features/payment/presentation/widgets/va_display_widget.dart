import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for displaying Virtual Account number
class VaDisplayWidget extends StatelessWidget {
  const VaDisplayWidget({
    super.key,
    required this.vaNumber,
    required this.bankName,
  });

  final String vaNumber;
  final String bankName;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: vaNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor VA berhasil disalin'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer ke $bankName',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nomor Virtual Account:',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                vaNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(context),
              tooltip: 'Salin nomor VA',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gunakan menu "Transfer" di aplikasi $bankName atau ATM. Masukkan nomor VA di atas dengan tepat.',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}