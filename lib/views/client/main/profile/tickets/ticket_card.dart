import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/ticket.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);
    final DateTime movieTime = ticket.schedule.time.toDate();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: colors.classicDecorationDarkSharper,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 130,
              height: 190,
              child: CachedNetworkImage(
                imageUrl: ticket.schedule.movie.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: colors.classicDecorationSharper,
                      child: Text(
                        ticket.schedule.movie.title,
                        style: bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      Icons.calendar_today,
                      DateFormat('dd.MM.yyyy').format(movieTime),
                    ),
                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      DateFormat('HH:mm').format(movieTime),
                    ),
                    _buildDetailRow(
                      context,
                      Icons.chair,
                      "Rinda: ${ticket.seat['row'] + 1}, Vieta: ${ticket.seat['seat'] + 1}",
                    ),
                    _buildDetailRow(
                      context,
                      Icons.meeting_room,
                      "${ticket.schedule.hall}. zāle",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    final colors = ColorContext.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            icon,
            size: 16,
            color: colors.color003,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}