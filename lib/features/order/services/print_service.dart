import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:logger/logger.dart';

/// Service untuk print receipt via Bluetooth thermal printer
/// ponytail: connection state management, proper ESC/POS encoding, reconnect logic
class PrintService {
  PrintService();

  final Logger _log = Logger();

  // ponytail: singleton connection state untuk track koneksi aktif
  BluetoothDevice? _currentDevice;
  bool _isConnected = false;
  DateTime? _lastPrintTime;

  /// Select device via native picker
  Future<BluetoothDevice?> selectDevice(BuildContext context) async {
    try {
      _log.i('[PrintService] Opening device picker...');
      _currentDevice = await FlutterBluetoothPrinter.selectDevice(context);
      if (_currentDevice != null) {
        _isConnected = false; // reset state, akan connect saat print
        _log.i('[PrintService] Device selected: ${_currentDevice!.name ?? _currentDevice!.address}');
      }
      return _currentDevice;
    } catch (e, st) {
      _log.e('[PrintService] Failed to select device', error: e, stackTrace: st);
      return null;
    }
  }

  /// Print raw bytes to device with proper connection management
  Future<bool> printBytes({
    required String address,
    required Uint8List bytes,
    bool keepConnected = true, // ponytail: default true untuk multi-print
  }) async {
    try {
      // ponytail: cek apakah kita perlu reconnect
      final needsReconnect = !_isConnected || _currentDevice?.address != address;

      if (needsReconnect) {
        _log.i('[PrintService] Connecting to printer: $address');
        await _reconnect(address);
      }

      _log.d('[PrintService] Sending ${bytes.length} bytes to printer');
      _log.t('[PrintService] Bytes preview: ${_hexPreview(bytes)}');

      await FlutterBluetoothPrinter.printBytes(
        data: bytes,
        address: address,
        keepConnected: keepConnected,
      );

      _lastPrintTime = DateTime.now();
      _isConnected = keepConnected;
      _log.i('[PrintService] Print success to: $address (keepConnected: $keepConnected)');
      return true;
    } catch (e, st) {
      _log.e('[PrintService] Print failed', error: e, stackTrace: st);
      _isConnected = false;
      return false;
    }
  }

  /// Reconnect to device with retry logic
  Future<void> _reconnect(String address) async {
    try {
      _log.i('[PrintService] Attempting reconnect to: $address');
      // ponytail: connect dengan timeout, flush buffer printer lama
      await Future.delayed(const Duration(milliseconds: 500)); // ponytail: wait for BT stack
      await FlutterBluetoothPrinter.printBytes(
        data: Uint8List(0), // ponytail: flush command untuk reset buffer
        address: address,
        keepConnected: true,
      );
      _isConnected = true;
      _log.i('[PrintService] Reconnect successful');
    } catch (e) {
      _log.w('[PrintService] Reconnect failed, will retry on next print');
      _isConnected = false;
    }
  }

  /// Print ESC/POS command string with proper encoding
  Future<bool> printCommand({
    required String address,
    required String command,
    bool keepConnected = true,
  }) async {
    try {
      final bytes = _encodeCommand(command);
      return await printBytes(
        address: address,
        bytes: bytes,
        keepConnected: keepConnected,
      );
    } catch (e, st) {
      _log.e('[PrintService] Command print failed', error: e, stackTrace: st);
      return false;
    }
  }

  /// Build ESC/POS receipt and print
  Future<bool> printReceipt({
    required String address,
    required Map<String, dynamic> orderData,
    bool keepConnected = true,
  }) async {
    try {
      _log.i('[PrintService] Building receipt for order: ${orderData['invoice']}');

      final receipt = _buildReceipt(orderData);
      final bytes = _encodeCommand(receipt);

      _log.d('[PrintService] Receipt size: ${bytes.length} bytes');
      _log.t('[PrintService] Receipt preview:\n${receipt.substring(0, receipt.length > 200 ? 200 : receipt.length)}...');

      return await printBytes(
        address: address,
        bytes: bytes,
        keepConnected: keepConnected,
      );
    } catch (e, st) {
      _log.e('[PrintService] Receipt print failed', error: e, stackTrace: st);
      return false;
    }
  }

  /// Encode string to ESC/POS bytes using LATIN-1 (ISO-8859-1)
  /// ponytail: ESC/POS printers menggunakan encoding yang berbeda dari UTF-8
  /// LATIN-1 compatible dengan ASCII dan support karakter Western European
  Uint8List _encodeCommand(String command) {
    // ponytail: dart:convert dengan LATIN-1 encoding untuk ESC/POS compatibility
    // Pastikan semua karakter bisa diencode dengan benar untuk thermal printer
    try {
      // Fallback encoding yang paling compatible untuk thermal printer 58mm
      return Uint8List.fromList(latin1.encode(command));
    } catch (e) {
      // ponytail: jika gagal, fallback ke ASCII only (filter karakter non-ASCII)
      _log.w('[PrintService] Latin-1 encoding failed, using ASCII fallback');
      final asciiBytes = <int>[];
      for (final char in command.codeUnits) {
        if (char <= 127) {
          asciiBytes.add(char);
        }
        //ponytail: skip karakter non-ASCII jika encoding gagal
      }
      return Uint8List.fromList(asciiBytes);
    }
  }

  /// Build receipt content in ESC/POS format
  String _buildReceipt(Map<String, dynamic> order) {
    final buffer = StringBuffer();

    // Initialize printer (reset)
    buffer.write('\x1B\x40'); // ESC @ (initialize)

    // Text alignment: center
    buffer.write('\x1B\x61\x31'); // ESC a n (n=1 center)

    // Header with bold
    buffer.write('\x1B\x45\x01'); // ESC E n (bold on)
    buffer.writeln('================================');
    buffer.writeln('       WARMINDO PURNAMA         ');
    buffer.writeln('================================');
    buffer.write('\x1B\x45\x00'); // ESC E n (bold off)

    buffer.writeln('');

    // Text alignment: left
    buffer.write('\x1B\x61\x30'); // ESC a n (n=0 left)

    // Invoice info
    buffer.writeln('Invoice : ${order['invoice'] ?? '-'}');
    buffer.writeln('Tanggal : ${order['date'] ?? '-'}');
    buffer.writeln('Kasir   : ${order['cashier'] ?? '-'}');
    buffer.writeln('--------------------------------');
    buffer.writeln('');

    // Items
    final items = order['items'] as List<dynamic>? ?? [];
    for (final item in items) {
      final name = item['name'] ?? '';
      final qty = item['qty'] ?? 0;
      final price = item['price'] ?? 0;
      buffer.writeln('$name');
      buffer.writeln('  ${qty}x ${_formatRupiah(price)}');
    }

    buffer.writeln('');
    buffer.writeln('--------------------------------');

    // Totals - bold
    buffer.write('\x1B\x45\x01'); // ESC E n (bold on)
    buffer.writeln('TOTAL       : ${_formatRupiah(order['total'] ?? 0)}');
    buffer.write('\x1B\x45\x00'); // ESC E n (bold off)
    buffer.writeln('================================');
    buffer.writeln('');

    // Text alignment: center
    buffer.write('\x1B\x61\x31'); // ESC a n (n=1 center)
    buffer.writeln('     Terima Kasih!           ');
    buffer.writeln('');

    // ponytail: feed paper sebelum cut agar tidak terpotong setengah
    buffer.writeln(''); // extra line feed
    buffer.write('\x1A'); // ponytail: GS V (0x1D 0x56) = full cut, tapi \x1A = SEL feed + cut

    // ponytail: alternatif cut command yang lebih aman
    // GS V m = 0x1D 0x56, m=0 = full cut, m=1 = partial cut
    // buffer.write('\x1D\x56\x30'); // GS V 0 (full cut)
    // buffer.write('\x1D\x56\x31'); // GS V 1 (partial cut)

    return buffer.toString();
  }

  /// Format number to Indonesian Rupiah
  String _formatRupiah(dynamic amount) {
    final value = (amount is int) ? amount : int.tryParse(amount.toString()) ?? 0;
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  /// Debug helper: convert bytes to hex string preview
  String _hexPreview(Uint8List bytes) {
    final preview = bytes.take(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    return bytes.length > 16 ? '$preview...' : preview;
  }

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Get last print time
  DateTime? get lastPrintTime => _lastPrintTime;

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    try {
      _log.i('[PrintService] Disconnecting...');
      _isConnected = false;
      _currentDevice = null;
      _log.i('[PrintService] Disconnected');
    } catch (e, st) {
      _log.e('[PrintService] Disconnect error', error: e, stackTrace: st);
    }
  }
}
