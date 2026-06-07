import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import '../routes/app_router.dart';

/// Background message handler — WAJIB top-level function (bukan static method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tidak bisa akses BuildContext di sini
  // Android auto-tampilkan notif dari notification payload
  Logger().i('[FCM Background] ${message.notification?.title} | data: ${message.data}');
}

/// Service untuk mengelola push notification Firebase (FCM) dan local notifications.
///
/// Semua method adalah static. Class ini tidak diinstansiasi.
class NotificationService {
  NotificationService._();

  static final Logger _log = Logger();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'warmindo_channel';
  static const _channelName = 'Warmindo Notifications';

  /// Inisialisasi FCM dan local notifications.
  ///
  /// WAJIB dipanggil setelah user login (dari _saveSession di AuthProvider).
  /// Silent fail — tidak akan crash jika terjadi error.
  static Future<void> initialize({
    required Future<void> Function(String token) onTokenReceived,
  }) async {
    try {
      // 1. Daftarkan background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Minta permission notifikasi
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      _log.i('[NotificationService] Authorization status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _log.w('[NotificationService] Permission ditolak, FCM tidak aktif.');
        return;
      }

      // 3. Setup local notifications
      await _setupLocalNotifications();

      // 4. Setup & kirim FCM token
      await _setupToken(onTokenReceived);

      // 5. Handle notif saat app di foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Handle tap notif saat app di background (sudah running)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // 7. Handle tap notif saat app terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _handleNotificationTap(initialMessage);
      }
    } catch (e, st) {
      _log.e('[NotificationService] Inisialisasi gagal', error: e, stackTrace: st);
      // JANGAN rethrow — silent fail
    }
  }

  /// Setup local notification plugin dan channel (Android).
  static Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Notifikasi untuk Warmindo Purnama',
          importance: Importance.high,
          playSound: true,
        ),
      );
    }
  }

  /// Ambil FCM token dan kirim ke backend via callback.
  static Future<void> _setupToken(
    Future<void> Function(String) onTokenReceived,
  ) async {
    try {
      // iOS perlu APNS token dulu sebelum bisa dapat FCM token
      if (Platform.isIOS) {
        await _messaging.getAPNSToken();
      }

      final token = await _messaging.getToken();
      if (token == null) {
        _log.w('[NotificationService] FCM token null — mungkin emulator tanpa Google Play');
        return;
      }

      _log.i('[NotificationService] FCM token didapat');
      await onTokenReceived(token);

      // Listen untuk token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        _log.i('[NotificationService] FCM token diperbarui');
        try {
          await onTokenReceived(newToken);
        } catch (e) {
          _log.w('[NotificationService] Gagal update token baru: $e');
        }
      });
    } catch (e, st) {
      _log.e('[NotificationService] Gagal setup token', error: e, stackTrace: st);
    }
  }

  /// Handle notifikasi masuk saat app di foreground.
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _log.i('[NotificationService] Foreground: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: notification.android?.smallIcon ?? '@mipmap/ic_launcher',
          color: const Color(0xFFFF5722),
          showWhen: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _encodePayload(message.data),
    );
  }

  /// Handle tap pada notifikasi FCM (background/terminated).
  static void _handleNotificationTap(RemoteMessage message) {
    _log.i('[NotificationService] Notif di-tap: ${message.data}');
    _navigateFromData(message.data);
  }

  /// Handle tap pada local notification.
  static void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = _decodePayload(response.payload!);
      _navigateFromData(data);
    } catch (e) {
      _log.w('[NotificationService] Gagal parse payload notif: $e');
    }
  }

  /// Navigasi ke halaman yang sesuai berdasarkan data payload notifikasi.
  static void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final orderId = data['order_id'] as String?;
    if (type == null) return;

    final navigator = AppRouter.navigatorKey.currentState;
    if (navigator == null) {
      _log.w('[NotificationService] Navigator belum siap');
      return;
    }

    switch (type) {
      case 'payment_success':
      case 'payment_completed':
        if (orderId != null) {
          navigator.pushNamed(
            AppRouter.orderDetail,
            arguments: int.tryParse(orderId),
          );
        }
        break;
      case 'new_order':
        navigator.pushNamed(AppRouter.orderList);
        break;
      default:
        _log.w('[NotificationService] Unknown notif type: $type');
    }
  }

  // ---------------------------------------------------------------------------
  // Helper: encode/decode payload sebagai query-string sederhana
  // ---------------------------------------------------------------------------

  /// Encode Map ke string: 'key1=val1&key2=val2'
  static String _encodePayload(Map<String, dynamic> data) =>
      data.entries.map((e) => '${e.key}=${e.value}').join('&');

  /// Decode string ke Map
  static Map<String, dynamic> _decodePayload(String payload) =>
      Map.fromEntries(
        payload.split('&').map((e) {
          final parts = e.split('=');
          return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
        }),
      );
}
