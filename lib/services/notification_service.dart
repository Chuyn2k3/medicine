// lib/services/notification_service.dart
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Thông báo quan trọng',
    description: 'Kênh dùng để hiển thị các thông báo thuốc',
    importance: Importance.high,
  );

  /// Gọi 1 lần trong main() sau Firebase.initializeApp()
  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // TODO: xử lý khi user bấm vào thông báo (foreground/background)
        // response.payload có thể chứa id thuốc, v.v.
      },
    );

    // Tạo channel cho Android
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Hiển thị local notification từ RemoteMessage (dùng cho foreground / background handler)
  static Future<void> showFcmNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    final title = notification?.title ?? 'Thông báo';
    final body = notification?.body ?? 'Bạn có một thông báo mới';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
      icon: android?.smallIcon ?? '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      Random().nextInt(1 << 31),
      title,
      body,
      details,
      payload: message.data['payload']?.toString(),
    );
  }
}
