import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationController {
  final notifications = FlutterLocalNotificationsPlugin();

  bool isInit = false;

  Future<void> initialize() async {
    if (isInit) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await notifications.initialize(settings);
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('daily_channel_id', 'Daily Notifications', channelDescription: 'desc', importance: Importance.max, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification(int id, String title, String body) async {
    return notifications.show(id, title, body, notificationDetails());
  }
}