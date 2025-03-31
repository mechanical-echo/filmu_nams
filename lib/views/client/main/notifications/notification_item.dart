import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../controllers/notification_controller.dart';
import '../../../../models/notification.dart';
import '../../../../providers/color_context.dart';
import '../../../admin/dashboard/widgets/stylized_button.dart';
import 'notifications.dart';

class NotificationItem extends StatefulWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  final NotificationModel notification;
  final Function() onDelete;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool isExpanded = false;
  bool isLoading = false;
  late NotificationModel _notification;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
  }

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

  NotificationTitle() {
    return Text(
      _notification.message,
      style: GoogleFonts.poppins(
        color: Colors.white,
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
    final colors = ColorContext.of(context);
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
          decoration: _notification.status == NotificationStatusEnum.unread
              ? colors.classicDecoration
              : colors.classicDecorationDark,
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

  NotificationReadButton(BuildContext context) {
    final colors = ColorContext.of(context);
    return StylizedButton(
      action: _toggleRead,
      title:
      "Atzimēt kā ${_notification.status == NotificationStatusEnum.unread ? "izlasīto" : "neizlasīto"}",
      textStyle: colors.bodySmallThemeColor,
      horizontalPadding: 15,
    );
  }

  NotificationDeleteButton(BuildContext context) {
    final colors = ColorContext.of(context);
    return StylizedButton(
      action: _onDelete,
      title: "Dzēst",
      textStyle: colors.bodySmallThemeColor,
      horizontalPadding: 15,
    );
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _toggleRead() async {
    setState(() {
      isLoading = true;
    });

    final status =
    _notification.status == NotificationStatusEnum.read
        ? NotificationStatusEnum.unread
        : NotificationStatusEnum.read;
    try{
      final response = await NotificationController().updateNotificationStatus(_notification.id, status);
      setState(() {
        _notification = response;
      });
    } catch(e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onDelete() async {
    setState(() {
      isLoading = true;
    });

    final status = NotificationStatusEnum.deleted;
    try{
      await NotificationController().updateNotificationStatus(_notification.id, status);
      widget.onDelete();
    } catch(e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }
}