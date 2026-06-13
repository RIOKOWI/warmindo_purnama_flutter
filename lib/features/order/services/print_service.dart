import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:logger/logger.dart';

/// Service untuk print receipt via Bluetooth thermal printer
class PrintService {
  PrintService();

  final Logger _log = Logger();

  /// Select device via native picker
  Future<BluetoothDevice?> selectDevice(BuildContext context) async {
    try {
      return await FlutterBluetoothPrinter.selectDevice(context);
    } catch (e, st) {
      _log.e('[PrintService] Failed to select device', error: e, stackTrace: st);
      return null;
    }
  }

  /// Print raw bytes to device
  Future<bool> printBytes({
    required String address,
    required Uint8List bytes,
    bool keepConnected = false,
  }) async {
    try {
      await FlutterBluetoothPrinter.printBytes(
        data: bytes,
        address: address,
        keepConnected: keepConnected,
      );
      _log.i('[PrintService] Print success to: $address');
      return true;
    } catch (e, st) {
      _log.e('[PrintService] Print failed', error: e, stackTrace: st);
      return false;
    }
  }

  /// Print ESC/POS command string
  Future<bool> printCommand({
    required String address,
    required String command,
    bool keepConnected = false,
  }) async {
    try {
      final bytes = _encodeCommand(command);
      return await printBytes(address: address, bytes: bytes, keepConnected: keepConnected);
    } catch (e, st) {
      _log.e('[PrintService] Command print failed', error: e, stackTrace: st);
      return false;
    }
  }

  /// Build ESC/POS receipt and print
  Future<bool> printReceipt({
    required String address,
    required Map<String, dynamic> orderData,
    bool keepConnected = false,
  }) async {
    try {
      final receipt = _buildReceipt(orderData);
      final bytes = _encodeCommand(receipt);
      await FlutterBluetoothPrinter.printBytes(
        data: bytes,
        address: address,
        keepConnected: keepConnected,
      );
      _log.i('[PrintService] Receipt printed successfully');
      return true;
    } catch (e, st) {
      _log.e('[PrintService] Receipt print failed', error: e, stackTrace: st);
      return false;
    }
  }

  /// Encode string to ESC/POS bytes
  Uint8List _encodeCommand(String command) {
    return Uint8List.fromList(command.codeUnits);
  }

  /// Build receipt content in ESC/POS format
  String _buildReceipt(Map<String, dynamic> order) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('================================');
    buffer.writeln('       WARMINDO PURNAMA         ');
    buffer.writeln('================================');
    buffer.writeln('');

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

    // Totals
    buffer.writeln('Subtotal    : ${_formatRupiah(order['subtotal'] ?? 0)}');
    buffer.writeln('Pajak (10%) : ${_formatRupiah(order['tax'] ?? 0)}');
    buffer.writeln('================================');
    buffer.writeln('TOTAL       : ${_formatRupiah(order['total'] ?? 0)}');
    buffer.writeln('================================');
    buffer.writeln('');
    buffer.writeln('     Terima Kasih!           ');
    buffer.writeln('');
    buffer.writeln('');

    // Cut paper
    buffer.write('\x1B\x69'); // ESC i (cut)

    return buffer.toString();
  }

  String _formatRupiah(dynamic amount) {
    final value = (amount is int) ? amount : int.tryParse(amount.toString()) ?? 0;
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
