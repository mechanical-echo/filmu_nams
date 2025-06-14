import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/models/ticket_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TicketCard extends StatefulWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  Style get theme => Style.of(context);

  @override
  Widget build(BuildContext context) {
    final DateTime movieTime = widget.ticket.schedule.time.toDate();
    final bool isExpired = movieTime.isBefore(DateTime.now());
    final bool isUsed = widget.ticket.status == TicketStatusEnum.used ||
        widget.ticket.status == TicketStatusEnum.expiredUsed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
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
                      imageUrl: widget.ticket.schedule.movie.posterUrl,
                      width: 130,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 150,
                        color: theme.contrast.withAlpha(15),
                        child: Center(
                          child: LoadingAnimationWidget.stretchedDots(
                            color: theme.contrast,
                            size: 30,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 150,
                        color: theme.contrast.withAlpha(15),
                        child: Icon(
                          Icons.movie_outlined,
                          color: theme.contrast.withAlpha(76),
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
                            widget.ticket.schedule.movie.title,
                            style: GoogleFonts.poppins(
                              color: theme.contrast.withAlpha(229),
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
                            "Rinda: ${widget.ticket.seat['row'] + 1}, Vieta: ${widget.ticket.seat['seat'] + 1}",
                          ),
                          _buildDetailRow(
                            Icons.meeting_room,
                            "${widget.ticket.schedule.hall}. zāle",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isExpired || isUsed)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isUsed
                        ? Colors.green.withAlpha(40)
                        : Colors.red.withAlpha(40),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isUsed ? 'Izlietota' : 'Novecojusi',
                      style: GoogleFonts.poppins(
                        color: isUsed ? Colors.green[300] : Colors.red[300],
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
            color: theme.contrast.withAlpha(125),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: theme.contrast.withAlpha(178),
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
