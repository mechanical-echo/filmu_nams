import 'package:filmu_nams/models/notification_model.dart';
import 'package:filmu_nams/providers/theme.dart';
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
        sortNotifications();
      });
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  void sortNotifications() {
    setState(() {
      notifications.sort((a, b) => b.status.compareTo(a.status));
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Style.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Paziņojumi 🔔',
            style: theme.displaySmall,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: notifications.isNotEmpty
                ? ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NotificationItem(
                          notification: notifications[index],
                          onDelete: fetchNotifications,
                          onStatusChange: sortNotifications,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: theme.contrast.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nav paziņojumu',
                          style: theme.titleMedium,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
