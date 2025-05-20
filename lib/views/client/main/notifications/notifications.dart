import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/models/notification_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  final NotificationController _controller = NotificationController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _notificationFetchSubscription;

  bool isLoading = false;

  Future<void> fetchNotifications() async {
    final user = FirebaseAuth.instance.currentUser;

    final userRef = _firestore.collection('users').doc(user!.uid);

    _notificationFetchSubscription = _firestore
        .collection('notifications')
        .where('user', isEqualTo: userRef)
        .where('status', isNotEqualTo: 'deleted')
        .orderBy('status', descending: true)
        .snapshots()
        .listen((snapshot) async {
      final notificaitonDocs = snapshot.docs.map(
        (doc) => NotificationModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(notificaitonDocs.toList());

      setState(() {
        notifications = [...items];
      });
    }, onError: (e) {
      debugPrint('Error listening to notification changes: $e');
    }, onDone: () {});
  }

  void _markAllAsRead() {
    _controller.markAllAsRead();
  }

  void _changeStatus(String id, String status) {
    _controller.updateNotificationStatus(id, status);
  }

  // void _returnDeleted() {
  //   _controller.returnDeleted();
  // }

  void _deleteAll() {
    StylizedDialog.dialog(
      Icons.warning,
      context,
      "Vai tiešām vēlāties dzēst?",
      "Vai tiešām vēlāties dzēst visus paziņojumus no saraksta?",
      onConfirm: () => _controller.deleteAll(),
      onCancel: () {},
      confirmText: "Dzēst",
    );
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  void dispose() {
    _notificationFetchSubscription?.cancel();
    super.dispose();
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Paziņojumi 🔔',
                  style: theme.displaySmall,
                ),
              ),
              IconButton(
                onPressed: _markAllAsRead,
                icon: Icon(Icons.mark_email_read),
              ),
              IconButton(
                onPressed: _deleteAll,
                icon: Icon(Icons.delete_rounded),
              ),
              // TIKAI PRIEKS DEBUG:
              // IconButton(
              //   onPressed: _returnDeleted,
              //   icon: Icon(Icons.assignment_return_outlined),
              // ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 70,
                    ),
                  )
                : notifications.isNotEmpty
                    ? ListView.builder(
                        key: ValueKey(notifications.length),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: NotificationItem(
                              key: ValueKey(notifications[index].id +
                                  notifications[index].status),
                              onDelete: () => _changeStatus(
                                  notifications[index].id, "deleted"),
                              onStatusToggle: () => _changeStatus(
                                notifications[index].id,
                                notifications[index].status == "read"
                                    ? "unread"
                                    : "read",
                              ),
                              notification: notifications[index],
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
                              color: theme.contrast.withAlpha(76),
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
