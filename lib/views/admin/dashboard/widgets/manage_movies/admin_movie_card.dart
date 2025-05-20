import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/edit_movie_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AdminMovieCard extends StatefulWidget {
  const AdminMovieCard({
    super.key,
    required this.data,
  });

  final MovieModel data;

  @override
  State<AdminMovieCard> createState() => _AdminMovieCardState();
}

class _AdminMovieCardState extends State<AdminMovieCard> {
  bool isHovered = false;

  Style get theme => Style.of(context);

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}min';
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Card(
        margin: const EdgeInsets.all(0),
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: InkWell(
          onTap: () {
            showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryAnimation) {
                return EditMovieDialog(data: widget.data);
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            );
          },
          child: Container(
            decoration:
                isHovered ? theme.activeCardDecoration : theme.cardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildPosterImage(),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildMovieInfo(),
                      ),
                      const SizedBox(width: 8),
                      _buildMetadataSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage() {
    return Container(
      width: 80,
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CachedNetworkImage(
        imageUrl: widget.data.posterUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: theme.primary,
            size: 30,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(Icons.movie_filter, color: theme.primary, size: 30),
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.title,
          style: theme.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.data.description,
          style:
              theme.bodyMedium.copyWith(color: theme.contrast.withAlpha(178)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildInfoChip(
              Icons.person,
              widget.data.director,
              tooltip: 'Režisors',
            ),
            _buildInfoChip(
              Icons.category,
              widget.data.genre,
              tooltip: 'Žanrs',
            ),
            _buildInfoChip(
              Icons.star_border,
              widget.data.rating,
              tooltip: 'Reitings',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withAlpha(50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.outline.withAlpha(76)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primary.withAlpha(76)),
          ),
          child: Text(
            _formatDuration(widget.data.duration),
            style: theme.titleSmall.copyWith(color: theme.primary),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: theme.contrast.withAlpha(178)),
              const SizedBox(width: 4),
              Text(
                _formatDate(widget.data.premiere),
                style: theme.bodySmall
                    .copyWith(color: theme.contrast.withAlpha(178)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
