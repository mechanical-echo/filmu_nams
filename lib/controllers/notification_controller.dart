import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/user.dart';

class NotificationController {
  final notifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      android: AndroidNotificationDetails(
          'daily_channel_id', 'Daily Notifications',
          channelDescription: 'desc',
          importance: Importance.max,
          priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification(
    int id,
    String title,
    String body,
    String fullMessage,
    String type,
  ) async {
    createNotificationDoc(title, fullMessage, type);
    return notifications.show(id, title, body, notificationDetails());
  }

  Future<void> createNotificationDoc(
      String title, String body, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = _firestore.collection('users').doc(user!.uid);

    await _firestore.collection('notifications').add({
      'message': body,
      'status': NotificationStatusEnum.unread,
      'title': title,
      'type': type,
      'user': userRef,
    });
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = _firestore.collection('users').doc(user!.uid);

    final snapshot = await _firestore
        .collection('notifications')
        .where('user', isEqualTo: userRef)
        .where('status', isNotEqualTo: NotificationStatusEnum.deleted)
        .get();
    List<NotificationModel> notifications = [];

    for (var doc in snapshot.docs) {
      final n = await NotificationModel.fromMapAsync(
        doc.data(),
        doc.id,
      );
      notifications.add(n);
    }

    return notifications;
  }

  Future<NotificationModel> updateNotificationStatus(String id, String status) async {
      await _firestore.collection('notifications').doc(id).update({
        'status': status,
      });
      return await getNotificationById(id);
  }

  Future<NotificationModel> getNotificationById(String id) async {
    final snapshot = await _firestore.collection('notifications').doc(id).get();
    return await NotificationModel.fromMapAsync(
      snapshot.data()!,
      snapshot.id,
    );
  }
}

class NotificationStatusEnum {
  static const deleted = 'deleted';
  static const unread = 'unread';
  static const read = 'read';
}

class NotificationTypeEnum {
  static const payment = 'payment';
  static const reminder = 'reminder';
  static const other = 'other';
}
