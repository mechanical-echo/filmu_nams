import 'package:filmu_nams/models/notification.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import '../../../../controllers/notification_controller.dart';
import 'notification_item.dart';

IconData getNotificationIcon(String type) {
  switch (type) {
    case NotificationTypeEnum.payment:
      return Icons.payment;
    case NotificationTypeEnum.reminder:
      return Icons.notifications;
    default:
      return Icons.new_releases_outlined;
  }
}

class Notification {
  Notification({
    required this.title,
    required this.message,
    this.state = NotificationStatusEnum.unread,
    this.type = NotificationTypeEnum.other,
  });

  final String title;
  final String message;

  String state;
  String type;
}

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<NotificationModel> notifications = [];

  Future<void> fetchNotifications() async {
    try {
      final response = await NotificationController().fetchNotifications();
      setState(() {
        notifications = response;
      });
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 110.0, bottom: 125),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: notifications.isNotEmpty
              ? Column(
            children: List.generate(
              notifications.length,
                  (index) => NotificationItem(
                notification: notifications[index],
                onDelete: fetchNotifications,
              ),
            ),
          )
              : Center(
            child: Text(
              "Nav paziņojumu",
              style: colors.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

