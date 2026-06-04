import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

/// Widget for displaying QRIS QR code with download capability
class QrisDisplayWidget extends StatefulWidget {
  const QrisDisplayWidget({
    super.key,
    required this.qrString,
  });

  final String qrString;

  @override
  State<QrisDisplayWidget> createState() => _QrisDisplayWidgetState();
}

class _QrisDisplayWidgetState extends State<QrisDisplayWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  Future<void> _downloadQrCode() async {
    setState(() => _isSaving = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes != null) {
        await Gal.putImageBytes(
          imageBytes,
          album: 'QRIS',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code berhasil disimpan ke galeri!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan QR Code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
        // Wrap only the QR container with Screenshot widget
        Screenshot(
          controller: _screenshotController,
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
              data: widget.qrString,
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
        const SizedBox(height: 16),
        // Download button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _downloadQrCode,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(_isSaving ? 'Menyimpan...' : 'Unduh QR Code'),
          ),
        ),
      ],
    );
  }
}