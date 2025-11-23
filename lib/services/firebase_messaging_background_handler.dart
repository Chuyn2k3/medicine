// lib/firebase_messaging_background_handler.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medical_drug/services/notification_service.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Bắt buộc phải init Firebase trong background isolate
  await Firebase.initializeApp();

  // Nếu muốn tự custom UI cho data-only / mọi message:
  await NotificationService.showFcmNotification(message);
}
