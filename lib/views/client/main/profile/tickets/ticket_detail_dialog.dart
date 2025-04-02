import 'package:filmu_nams/models/ticket.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailDialog extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailDialog({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: colors.color001,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.color003.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.color003.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.schedule.movie.title,
                      style: GoogleFonts.poppins(
                        color: colors.smokeyWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Movie details section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Movie poster
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              ticket.schedule.movie.posterUrl,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 150,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.movie, color: Colors.white),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Movie info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow('Datums:', ticket.getFormattedShowDate(), colors),
                                _infoRow('Laiks:', ticket.getFormattedShowTime(), colors),
                                _infoRow('Zāle:', 'Zāle ${ticket.schedule.hall}', colors),
                                _infoRow('Vieta:', ticket.getSeatInfo(), colors),
                                _infoRow('Biļete iegādāta:', ticket.getFormattedDate(), colors),
                                const SizedBox(height: 4),
                                _buildDuration(ticket.schedule.movie.duration, colors),
                                const SizedBox(height: 4),
                                Text(
                                  ticket.schedule.movie.genre,
                                  style: TextStyle(
                                    color: colors.color003,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // QR Code section
                      _buildQRCode(context, colors),

                      const SizedBox(height: 16),

                      // Ticket ID
                      Text(
                        'Biļetes ID: ${ticket.id}',
                        style: colors.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.color002.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: FilledButton.icon(
                icon: const Icon(Icons.close),
                label: Text('Aizvērt', style: TextStyle(fontSize: 16)),
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.color003,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorContext colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: colors.bodyMedium,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.smokeyWhite,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration(int minutes, ColorContext colors) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    final durationText = hours > 0
        ? '${hours}h ${remainingMinutes}min'
        : '${remainingMinutes}min';

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: colors.smokeyWhite,
        ),
        const SizedBox(width: 4),
        Text(
          durationText,
          style: TextStyle(
            color: colors.smokeyWhite,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode(BuildContext context, ColorContext colors) {
    // Generate QR code data including ticket information
    final qrData = _generateQRData();

    return Column(
      children: [
        Text(
          'Biļete',
          style: TextStyle(
            color: colors.smokeyWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
            errorStateBuilder: (context, error) {
              return Center(
                child: Text(
                  'Kļūda QR koda ģenerēšanā',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
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