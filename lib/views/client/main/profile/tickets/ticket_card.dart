import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/ticket.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final bool isExpired = movieTime.isBefore(DateTime.now());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Movie poster and title section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ticket.schedule.movie.posterUrl,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 150,
                        color: Colors.white.withOpacity(0.05),
                        child: Center(
                          child: LoadingAnimationWidget.stretchedDots(
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 150,
                        color: Colors.white.withOpacity(0.05),
                        child: Icon(
                          Icons.movie_outlined,
                          color: Colors.white.withOpacity(0.3),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Movie title and details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.schedule.movie.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.calendar_today,
                            DateFormat('dd.MM.yyyy').format(movieTime),
                          ),
                          _buildDetailRow(
                            Icons.access_time,
                            DateFormat('HH:mm').format(movieTime),
                          ),
                          _buildDetailRow(
                            Icons.chair,
                            "Rinda: ${ticket.seat['row'] + 1}, Vieta: ${ticket.seat['seat'] + 1}",
                          ),
                          _buildDetailRow(
                            Icons.meeting_room,
                            "${ticket.schedule.hall}. zāle",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Status indicator
              if (isExpired)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Novecojusi',
                      style: GoogleFonts.poppins(
                        color: Colors.red[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
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
