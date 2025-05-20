import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/controllers/ticket_controller.dart';
import 'package:filmu_nams/models/ticket_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailDialog extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailDialog({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketDetailDialog> createState() => _TicketDetailDialogState();
}

class _TicketDetailDialogState extends State<TicketDetailDialog> {
  Style get style => Style.of(context);

  @override
  Widget build(BuildContext context) {
    final bool isExpired =
        widget.ticket.schedule.time.toDate().isBefore(DateTime.now());
    final bool isUsed = widget.ticket.status == TicketStatusEnum.used ||
        widget.ticket.status == TicketStatusEnum.expiredUsed;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: style.opaqueCardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: style.cardDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.ticket.schedule.movie.title,
                      style: style.headlineMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withAlpha(178),
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
                      Row(
                        spacing: 8,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.ticket.schedule.movie.posterUrl,
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 120,
                                height: 180,
                                color: Colors.black.withAlpha(15),
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
                                color: Colors.black.withAlpha(15),
                                child: Icon(
                                  Icons.movie_outlined,
                                  color: Colors.black.withAlpha(76),
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: style.cardDecoration,
                              child: Wrap(
                                spacing: 5,
                                children: [
                                  _buildDetailRow(
                                    Icons.calendar_today,
                                    '',
                                    widget.ticket.getFormattedShowDate(),
                                  ),
                                  _buildDetailRow(
                                    Icons.access_time,
                                    '',
                                    widget.ticket.getFormattedShowTime(),
                                  ),
                                  _buildDetailRow(
                                    Icons.meeting_room,
                                    '',
                                    'Zāle ${widget.ticket.schedule.hall}',
                                  ),
                                  _buildDetailRow(
                                    Icons.chair,
                                    'Vieta:',
                                    widget.ticket.getSeatInfo(),
                                  ),
                                  _buildDetailRow(
                                    Icons.shopping_cart_outlined,
                                    'Iegādāta:',
                                    widget.ticket.getFormattedDate(),
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
                          ),
                        ],
                      ),
                      if (!isUsed)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withAlpha(25),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Biļete',
                                style: style.bodyLarge,
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
                        'Biļetes ID: ${widget.ticket.id}',
                        style: GoogleFonts.poppins(
                          color: Colors.black.withAlpha(125),
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
                      ? Colors.green.withAlpha(25)
                      : Colors.red.withAlpha(25),
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
    return Row(
      spacing: 8,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withAlpha(125),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: textColor ?? Colors.white,
              fontSize: 14,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _generateQRData() {
    return '''
      {
        "ticketId": "${widget.ticket.id}",
        "movieTitle": "${widget.ticket.schedule.movie.title}",
        "hall": ${widget.ticket.schedule.hall},
        "showTime": "${widget.ticket.getFormattedShowDate()} ${widget.ticket.getFormattedShowTime()}",
        "seat": "${widget.ticket.getSeatInfo()}",
        "userId": "${widget.ticket.user.id}"
      }
    ''';
  }
}
