// lib/services/fcm_service.dart
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service.dart';

class FcmService {
  final FirebaseMessaging _messaging;
  String? _cachedToken;

  FcmService(this._messaging);

  String? get cachedToken => _cachedToken;

  /// Gọi 1 lần trong main() sau Firebase.initializeApp() + NotificationService.init()
  Future<void> init() async {
    await _requestPermission();

    // Lấy token ngay khi khởi động app
    _cachedToken = await _messaging.getToken();
    developer.log('FCM token (init): $_cachedToken', name: 'FcmService');

    // App đang mở (foreground) -> show local notification custom
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        'FCM onMessage: ${message.messageId}',
        name: 'FcmService',
      );
      NotificationService.showFcmNotification(message);
    });

    // User bấm notification để mở app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log(
        'FCM onMessageOpenedApp: ${message.messageId}',
        name: 'FcmService',
      );
      // TODO: điều hướng theo message.data nếu cần
    });

    // Token refresh -> update cache
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      developer.log('FCM token refreshed: $newToken', name: 'FcmService');
      _cachedToken = newToken;
    });
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log(
      'Notification permission: ${settings.authorizationStatus}',
      name: 'FcmService',
    );
  }

  /// Dùng ở AuthCubit: ưu tiên token cache, nếu chưa có thì lấy từ Firebase
  Future<String?> getFcmToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _messaging.getToken();
    developer.log('FCM token (lazy): $_cachedToken', name: 'FcmService');
    return _cachedToken;
  }
}
