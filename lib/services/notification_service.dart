// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ==============================
  // 1 CHANNEL SAJA UNTUK SEMUA
  // ==============================
  static const String _channelId = 'aeroport_main_channel';
  static const String _channelName = 'AeroPort Notifications';
  static const String _channelDesc =
      'Semua notifikasi AeroPort menggunakan channel ini.';

  static Future<void> initializeNotification() async {
    // --- INIT SETTINGS ---
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    // ==============================
    // BUAT CHANNEL (PENTING!!!)
    // ==============================
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max, // Popup dijamin muncul
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Request permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // ==============================
  //  TEST BUTTON NOTIFICATION
  // ==============================
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'AeroPort Test',
        );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      999, // id unik
      'Tes Berhasil! ✈️',
      'Notifikasi test AeroPort muncul dengan benar.',
      notifDetails,
      payload: 'test_payload',
    );
  }

  // ==============================
  //  NOTIF FAVORITE
  // ==============================
  static Future<void> showFlightFavoriteNotification({
    required String flightNumber,
    required String origin,
    required String destination,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          ticker: 'Favorit Tersimpan',
        );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    final title = 'Rute Disimpan! ✈️';
    final body =
        'Penerbangan $flightNumber ($origin → $destination) ditambahkan ke favorit.';

    await _plugin.show(
      flightNumber.hashCode % 1000000, // id unik
      title,
      body,
      notifDetails,
      payload: 'favorite_payload',
    );
  }
}
