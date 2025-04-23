import 'package:filmu_nams/models/promocode.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';

class PromocodeCard extends StatefulWidget {
  const PromocodeCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final PromocodeModel data;
  final Function(String) onEdit;

  @override
  State<PromocodeCard> createState() => _PromocodeCardState();
}

class _PromocodeCardState extends State<PromocodeCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ContextTheme.of(context);

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
          child: Row(
            children: [
              _buildCodeContainer(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoSection(),
              ),
              _buildDiscountValue(),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.edit, color: theme.primary),
                onPressed: () => widget.onEdit(widget.data.id),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeContainer() {
    final theme = ContextTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.confirmation_number, color: theme.primary, size: 24),
          const SizedBox(height: 4),
          Text(
            'KODS',
            style: theme.labelSmall.copyWith(
              color: theme.contrast.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final theme = ContextTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.data.name,
            style: theme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _getDiscountTypeText(),
            style: theme.bodyMedium
                .copyWith(color: theme.contrast.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountValue() {
    final theme = ContextTheme.of(context);

    String value = '';

    if (widget.data.percents != null) {
      value = '${widget.data.percents}%';
    } else if (widget.data.amount != null) {
      value = '${widget.data.amount!.toStringAsFixed(2)}€';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        value,
        style: theme.headlineSmall.copyWith(
          color: theme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getDiscountTypeText() {
    if (widget.data.percents != null) {
      return 'Procentuāla atlaide';
    } else if (widget.data.amount != null) {
      return 'Fiksēta summas atlaide';
    } else {
      return 'Nav atlaides';
    }
  }
}
