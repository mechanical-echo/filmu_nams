import 'package:filmu_nams/models/promocode_model.dart';
import 'package:filmu_nams/providers/style.dart';
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

  Style get theme => Style.of(context);

  @override
  Widget build(BuildContext context) {
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
          child: Row(
            children: [
              _buildCodeContainer(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoSection(),
              ),
              _buildDiscountValue(),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.primary.withAlpha(40),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Center(
        child: Icon(Icons.confirmation_number, color: theme.primary, size: 24),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Row(
      spacing: 8,
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
          style:
              theme.bodyMedium.copyWith(color: theme.contrast.withAlpha(178)),
        ),
      ],
    );
  }

  Widget _buildDiscountValue() {
    String value = '';

    if (widget.data.percents != null) {
      value = '${widget.data.percents}%';
    } else if (widget.data.amount != null) {
      value = '${widget.data.amount!.toStringAsFixed(2)}€';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primary.withAlpha(50),
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
