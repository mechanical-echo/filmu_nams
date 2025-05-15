import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/models/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailDialog extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailDialog({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpired =
        ticket.schedule.time.toDate().isBefore(DateTime.now());
    final bool isUsed = ticket.status == TicketStatusEnum.used ||
        ticket.status == TicketStatusEnum.expiredUsed;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.schedule.movie.title,
                      style: GoogleFonts.poppins(
                        color: Colors.black.withOpacity(0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: ticket.schedule.movie.posterUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 120,
                            height: 180,
                            color: Colors.black.withOpacity(0.05),
                            child: Center(
                              child: LoadingAnimationWidget.stretchedDots(
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 120,
                            height: 180,
                            color: Colors.black.withOpacity(0.05),
                            child: Icon(
                              Icons.movie_outlined,
                              color: Colors.black.withOpacity(0.3),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              Icons.calendar_today,
                              'Datums:',
                              ticket.getFormattedShowDate(),
                            ),
                            _buildDetailRow(
                              Icons.access_time,
                              'Laiks:',
                              ticket.getFormattedShowTime(),
                            ),
                            _buildDetailRow(
                              Icons.meeting_room,
                              'Zāle:',
                              'Zāle ${ticket.schedule.hall}',
                            ),
                            _buildDetailRow(
                              Icons.chair,
                              'Vieta:',
                              ticket.getSeatInfo(),
                            ),
                            _buildDetailRow(
                              Icons.shopping_cart_outlined,
                              'Iegādāta:',
                              ticket.getFormattedDate(),
                            ),
                            _buildDetailRow(
                              isUsed
                                  ? Icons.check_circle_outline
                                  : Icons.pending_outlined,
                              'Statuss:',
                              isUsed
                                  ? 'Izlietota'
                                  : isExpired
                                      ? 'Novecojusi'
                                      : 'Aktīva',
                              textColor: isUsed
                                  ? Colors.green[700]
                                  : isExpired
                                      ? Colors.red[700]
                                      : Colors.blue[700],
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!isUsed)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Biļete',
                                style: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: QrImageView(
                                  data: _generateQRData(),
                                  version: QrVersions.auto,
                                  size: 180,
                                  backgroundColor: Colors.white,
                                  errorStateBuilder: (context, error) {
                                    return Center(
                                      child: Text(
                                        'Kļūda QR koda ģenerēšanā',
                                        style: GoogleFonts.poppins(
                                          color: Colors.red[300],
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Biļetes ID: ${ticket.id}',
                        style: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpired || isUsed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isUsed
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    isUsed ? 'Izlietota' : 'Novecojusi',
                    style: GoogleFonts.poppins(
                      color: isUsed ? Colors.green[700] : Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? textColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.black.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: textColor ?? Colors.black.withOpacity(0.9),
                fontSize: 14,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _generateQRData() {
    return '''
      {
        "ticketId": "${ticket.id}",
        "movieTitle": "${ticket.schedule.movie.title}",
        "hall": ${ticket.schedule.hall},
        "showTime": "${ticket.getFormattedShowDate()} ${ticket.getFormattedShowTime()}",
        "seat": "${ticket.getSeatInfo()}",
        "userId": "${ticket.user.id}"
      }
    ''';
  }
}
