import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScheduleCard extends StatefulWidget {
  const ScheduleCard({
    super.key,
    required this.data,
    required this.onEdit,
    this.small = false,
  });

  final ScheduleModel data;
  final Function(String) onEdit;
  final bool small;

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool isHovered = false;

  Style get theme => Style.of(context);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onEdit(widget.data.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration:
              isHovered ? theme.activeCardDecoration : theme.cardDecoration,
          padding: EdgeInsets.only(right: widget.small ? 5 : 10),
          child: Row(
            children: [
              _buildPoster(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoSection(),
              ),
              const SizedBox(width: 16),
              _buildTimeInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return Container(
      width: 120,
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: widget.data.movie.posterUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 30,
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  Widget _buildInfoSection() {
    final theme = Style.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.data.movie.title,
          style: widget.small ? theme.bodyLarge : theme.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 10,
          children: [
            tag(Icons.meeting_room, 'Zāle ${widget.data.hall}'),
            tag(Icons.movie, _getMovieDuration()),
            tag(Icons.category, _capitalize(widget.data.movie.genre)),
          ],
        ),
      ],
    );
  }

  Row tag(IconData icon, String text) {
    return Row(
      spacing: 4,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: widget.small ? 10 : 16,
          color: theme.contrast.withAlpha(178),
        ),
        Text(
          text,
          style: widget.small
              ? theme.bodySmall.copyWith(
                  color: theme.contrast.withAlpha(178),
                )
              : theme.bodyMedium.copyWith(
                  color: theme.contrast.withAlpha(178),
                ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    final theme = Style.of(context);
    final date = widget.data.time.toDate();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: theme.accentCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(DateFormat('HH:mm').format(date), style: theme.titleMedium),
          if (!widget.small)
            Text(
              DateFormat('dd.MM.yyyy').format(date),
              style: theme.bodySmall.copyWith(
                color: theme.contrast.withAlpha(178),
              ),
            ),
        ],
      ),
    );
  }

  String _getMovieDuration() {
    final hours = widget.data.movie.duration ~/ 60;
    final minutes = widget.data.movie.duration % 60;
    return '${hours}h ${minutes}min';
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
