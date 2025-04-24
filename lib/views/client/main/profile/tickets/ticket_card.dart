import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/models/ticket_model.dart';
import 'package:filmu_nams/providers/theme.dart';
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
    final theme = Style.of(context);
    final DateTime movieTime = ticket.schedule.time.toDate();
    final bool isExpired = movieTime.isBefore(DateTime.now());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: theme.cardDecoration,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: ticket.schedule.movie.posterUrl,
                      width: 130,
                      height: 220,
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
              if (isExpired)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Novecojusi | Izlietota',
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
