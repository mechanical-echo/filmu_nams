import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../controllers/notification_controller.dart';
import '../../../../models/notification_model.dart';
import '../../../../providers/style.dart';
import 'notifications.dart';

class NotificationItem extends StatefulWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    required this.onDelete,
    required this.onStatusToggle,
  });

  final NotificationModel notification;
  final Function() onDelete;
  final Function() onStatusToggle;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  bool isLoading = false;
  NotificationModel get _notification => widget.notification;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Style get theme => Style.of(context);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: _notification.status == NotificationStatusEnum.unread
          ? theme.cardDecoration
          : theme.cardDecoration.copyWith(
              color: theme.themeBgColor.withAlpha(100),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.stretchedDots(
                      color: theme.contrast,
                      size: 40,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildMessage(),
                      if (isExpanded) ...[
                        const SizedBox(height: 16),
                        _buildActions(),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.notification.title,
            style: GoogleFonts.poppins(
              color: _notification.status == NotificationStatusEnum.unread
                  ? theme.contrast
                  : theme.contrast.withAlpha(178),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _notification.status == NotificationStatusEnum.unread
                ? theme.contrast.withAlpha(40)
                : theme.contrast.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            getNotificationIcon(widget.notification.type),
            color: _notification.status == NotificationStatusEnum.unread
                ? theme.contrast
                : theme.contrast.withAlpha(178),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Text(
      _notification.message,
      style: GoogleFonts.poppins(
        color: _notification.status == NotificationStatusEnum.unread
            ? theme.contrast.withAlpha(229)
            : theme.contrast.withAlpha(125),
        fontSize: 14,
      ),
      maxLines: isExpanded ? null : 2,
      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleRead,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.contrast.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _notification.status == NotificationStatusEnum.unread
                        ? Icons.check_circle_outline
                        : Icons.circle_outlined,
                    color: theme.contrast.withAlpha(178),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _notification.status == NotificationStatusEnum.unread
                        ? 'Atzīmēt kā izlasītu'
                        : 'Atzīmēt kā neizlasītu',
                    style: GoogleFonts.poppins(
                      color: theme.contrast.withAlpha(178),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onDelete,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: Colors.red.withAlpha(178),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dzēst',
                    style: GoogleFonts.poppins(
                      color: Colors.red.withAlpha(178),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _toggleRead() async {
    widget.onStatusToggle();
  }

  void _onDelete() async {
    widget.onDelete();
  }
}
