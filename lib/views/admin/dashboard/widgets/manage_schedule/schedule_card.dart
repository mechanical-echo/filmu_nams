import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:filmu_nams/providers/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScheduleCard extends StatefulWidget {
  const ScheduleCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final ScheduleModel data;
  final Function(String) onEdit;

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Style.of(context);

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
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              _buildPoster(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoSection(),
              ),
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
          style: theme.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.meeting_room,
                size: 16, color: theme.contrast.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              'Zāle ${widget.data.hall}',
              style: theme.bodyMedium
                  .copyWith(color: theme.contrast.withOpacity(0.7)),
            ),
            const SizedBox(width: 16),
            Icon(Icons.movie, size: 16, color: theme.contrast.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              _getMovieDuration(),
              style: theme.bodyMedium
                  .copyWith(color: theme.contrast.withOpacity(0.7)),
            ),
            const SizedBox(width: 16),
            Icon(Icons.category,
                size: 16, color: theme.contrast.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              _capitalize(widget.data.movie.genre),
              style: theme.bodyMedium
                  .copyWith(color: theme.contrast.withOpacity(0.7)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    final theme = Style.of(context);
    final date = widget.data.time.toDate();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('HH:mm').format(date),
            style: theme.headlineSmall.copyWith(
              color: theme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('dd.MM.yyyy').format(date),
            style: theme.bodySmall.copyWith(
              color: theme.contrast.withOpacity(0.7),
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
