import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum NotificationState { read, unread, deleted }

enum NotificationType { payment, reminder, other }

IconData getNotificationIcon(NotificationType type) {
  switch (type) {
    case NotificationType.payment:
      return Icons.payment;
    case NotificationType.reminder:
      return Icons.notifications;
    case NotificationType.other:
      return Icons.new_releases_outlined;
  }
}

class Notification {
  Notification({
    required this.title,
    required this.message,
    this.state = NotificationState.unread,
    this.type = NotificationType.other,
  });

  final String title;
  final String message;

  NotificationState state;
  NotificationType type;
}

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    List<Notification> notifications = [
      Notification(
        title: "Veiksmigs maksajums",
        message:
            "Sveicināti! Jūsu maksājums ir veiksmīgi apstrādāts un apmaksāts. Pasūtījuma detaļas: 1 piegušo biļete filmai “Lorem Ipsum”",
        type: NotificationType.payment,
      ),
      Notification(
        title: "Veiksmigs maksajums",
        message:
            "Sveicināti! Jūsu maksājums ir veiksmīgi apstrādāts un apmaksāts. Pasūtījuma detaļas: 1 piegušo biļete filmai “Lorem Ipsum”",
        state: NotificationState.read,
      ),
      Notification(
        title: "Veiksmigs maksajums",
        message:
            "Sveicināti! Jūsu maksājums ir veiksmīgi apstrādāts un apmaksāts. Pasūtījuma detaļas: 1 piegušo biļete filmai “Lorem Ipsum”",
        type: NotificationType.reminder,
      ),
      Notification(
        title: "Veiksmigs maksajums",
        message:
            "Sveicināti! Jūsu maksājums ir veiksmīgi apstrādāts un apmaksāts. Pasūtījuma detaļas: 1 piegušo biļete filmai “Lorem Ipsum”",
      ),
      Notification(
        title: "Veiksmigs maksajums",
        message:
            "Sveicināti! Jūsu maksājums ir veiksmīgi apstrādāts un apmaksāts. Pasūtījuma detaļas: 1 piegušo biļete filmai “Lorem Ipsum”",
      ),
      Notification(
        title: "Veiksmigs maksajums",
        message:
            "Sveicināti! Jūsu maksājums ir veiksmīgi apstrādāts un apmaksāts. Pasūtījuma detaļas: 1 piegušo biļete filmai “Lorem Ipsum”",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 110.0, bottom: 125),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            children: List.generate(
              notifications.length,
              (index) => NotificationItem(
                notification: notifications[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem extends StatefulWidget {
  const NotificationItem({super.key, required this.notification});

  final Notification notification;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool isExpanded = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return NotificationScreenBody(
      width,
      context,
      isLoading
          ? Loading()
          : NotificationBody(
              context,
              [
                NotificationTitleRow(),
                NotificationTitle(),
                if (isExpanded) NotificationButtons(context)
              ],
            ),
    );
  }

  Center Loading() {
    return Center(
      child: LoadingAnimationWidget.stretchedDots(
        size: 100,
        color: Colors.white,
      ),
    );
  }

  Padding NotificationTitleRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.notification.title,
            style: GoogleFonts.poppins(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Icon(
            getNotificationIcon(widget.notification.type),
            color: Colors.white60,
            size: 30,
          ),
        ],
      ),
    );
  }

  Text NotificationTitle() {
    return Text(
      widget.notification.message,
      style: GoogleFonts.poppins(
        color: Colors.grey[500],
        fontSize: 16,
      ),
      maxLines: isExpanded ? null : 2,
      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  AnimatedSize NotificationScreenBody(
    double width,
    BuildContext context,
    Widget child,
  ) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      alignment: Alignment.topCenter,
      curve: Cubic(.69, -0.29, .4, 1.73),
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: Container(
          padding:
              const EdgeInsets.only(top: 13, left: 18, right: 18, bottom: 20),
          margin: EdgeInsets.only(
            bottom: isExpanded ? 16 : 6,
            top: 6,
            left: 16,
            right: 16,
          ),
          width: width,
          decoration: BoxDecoration(
            color: widget.notification.state == NotificationState.unread
                ? Theme.of(context).disabledColor
                : Theme.of(context).cardColor,
            boxShadow: cardShadow,
            border: bottomBorder,
            borderRadius: BorderRadius.circular(5),
          ),
          child: child,
        ),
      ),
    );
  }

  Column NotificationBody(BuildContext context, List<Widget> children) {
    return Column(
      children: children,
    );
  }

  Padding NotificationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NotificationReadButton(context),
          NotificationDeleteButton(context),
        ],
      ),
    );
  }

  FilledButton NotificationReadButton(BuildContext context) {
    return FilledButton(
      onPressed: _toggleRead,
      style: FilledButton.styleFrom(
        fixedSize: Size(200, 40),
        backgroundColor: widget.notification.state == NotificationState.unread
            ? Theme.of(context).focusColor
            : Theme.of(context).disabledColor.withRed(100),
      ),
      child: Text(
        "Atzimēt kā ${widget.notification.state == NotificationState.unread ? "izlasīto" : "neizlasīto"}",
        style: GoogleFonts.poppins(fontSize: 15),
      ),
    );
  }

  FilledButton NotificationDeleteButton(BuildContext context) {
    return FilledButton(
      onPressed: _onDelete,
      style: FilledButton.styleFrom(
        fixedSize: Size(140, 40),
        backgroundColor: widget.notification.state == NotificationState.unread
            ? Theme.of(context).focusColor
            : Theme.of(context).disabledColor.withRed(100),
      ),
      child: Text(
        "Dzest",
        style: GoogleFonts.poppins(fontSize: 15),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _toggleRead() {
    // TODO: Implement changing notification's state in db

    setState(() {
      widget.notification.state =
          widget.notification.state == NotificationState.read
              ? NotificationState.unread
              : NotificationState.read;
    });
  }

  void _onDelete() {
    setState(() {
      isLoading = true;
    });

    // TODO: Implement notification deletion

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }
}
