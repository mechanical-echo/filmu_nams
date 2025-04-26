import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/controllers/payment_controller.dart';
import 'package:filmu_nams/models/payment_history_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PaymentCard extends StatefulWidget {
  const PaymentCard({
    super.key,
    required this.data,
  });

  final PaymentHistoryModel data;

  @override
  State<PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  bool isHovered = false;
  bool isExpanded = false;

  Style get theme => Style.of(context);

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.data.status == 'completed';

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: InkWell(
          onTap: () => setState(() => isExpanded = !isExpanded),
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
                      _buildStatusIndicator(isCompleted),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoSection(),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildMovieInfo(),
                      ),
                      Expanded(
                        child: _buildAmountSection(),
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: theme.primary,
                        ),
                        onPressed: () =>
                            setState(() => isExpanded = !isExpanded),
                      ),
                    ],
                  ),
                ),
                if (isExpanded) _buildExpandedDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isCompleted) {
    return Container(
      width: 8,
      height: 50,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: 'Klikšķiniet, lai kopētu',
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.data.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Maksājuma ID nokopēts'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.receipt, size: 16, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  'ID: ${widget.data.id}',
                  style: theme.titleMedium,
                ),
                const SizedBox(width: 4),
                Icon(Icons.copy,
                    size: 14, color: theme.contrast.withOpacity(0.5)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(widget.data.purchaseDate),
          style:
              theme.bodyMedium.copyWith(color: theme.contrast.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildMovieInfo() {
    final movie = widget.data.schedule.movie;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: theme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today,
                size: 14, color: theme.contrast.withOpacity(0.5)),
            const SizedBox(width: 4),
            Text(
              _formatDate(widget.data.schedule.time),
              style: theme.bodySmall
                  .copyWith(color: theme.contrast.withOpacity(0.7)),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.meeting_room,
                size: 14, color: theme.contrast.withOpacity(0.5)),
            const SizedBox(width: 4),
            Text(
              'Zāle ${widget.data.schedule.hall}',
              style: theme.bodySmall
                  .copyWith(color: theme.contrast.withOpacity(0.7)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    final isCompleted = widget.data.status == 'completed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${widget.data.amount.toStringAsFixed(2)}€',
          style: theme.headlineMedium.copyWith(
            color: isCompleted ? theme.contrast : Colors.red.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          PaymentHistoryStatusEnum.getStatus(widget.data.status),
          style: theme.bodySmall.copyWith(
            color: isCompleted ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surfaceVariant.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: theme.outline.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maksājuma detaļas',
            style: theme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Produkts',
            widget.data.product,
            copy: true,
            copyText: widget.data.schedule.id,
            copyLabel: 'Saraksta ID nokopēts',
          ),
          _buildDetailRow(
            'Lietotājs',
            "${widget.data.user.name}, uid: ${widget.data.user.id}",
            copy: true,
            copyText: widget.data.user.id,
            copyLabel: 'Lietotāja ID nokopēts',
          ),
          if (widget.data.tickets != null &&
              widget.data.tickets!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Biļetes:',
              style: theme.titleSmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.data.tickets!.map((ticket) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    ticket.getSeatInfo(),
                    style: theme.bodySmall.copyWith(color: theme.contrast),
                  ),
                );
              }).toList(),
            ),
          ],
          if (widget.data.status == 'failed' && widget.data.reason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kļūdas iemesls: ${widget.data.reason}',
                      style: theme.bodyMedium
                          .copyWith(color: Colors.red.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool copy = false,
    String copyText = '',
    String copyLabel = 'Teksts nokopēts',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: copy
                ? InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: copyText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(copyLabel),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: theme.bodyMedium,
                          ),
                        ),
                        Tooltip(
                          message: 'Klikšķiniet, lai kopētu',
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: theme.contrast.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    value,
                    style: theme.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd.MM.yyyy HH:mm').format(date.toDate());
    }
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }
}
