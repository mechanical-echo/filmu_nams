import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/models/offer_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OfferCard extends StatefulWidget {
  const OfferCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final OfferModel data;
  final Function(String) onEdit;

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Style.of(context);

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
              _buildImage(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoSection(),
              ),
              const SizedBox(width: 16),
              _buildPromocodeInfo(),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 120,
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: widget.data.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 30,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(Icons.image_not_supported),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final theme = Style.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.data.title,
          style: theme.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.data.description,
          style:
              theme.bodyMedium.copyWith(color: theme.contrast.withAlpha(178)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPromocodeInfo() {
    final theme = Style.of(context);

    if (widget.data.promocode == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Nav promokoda',
          style: theme.bodySmall.copyWith(color: theme.contrast.withAlpha(125)),
        ),
      );
    }

    final promocode = widget.data.promocode!;
    String value = '';

    if (promocode.percents != null) {
      value = '${promocode.percents}%';
    } else if (promocode.amount != null) {
      value = '${promocode.amount} EUR';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            promocode.name,
            style: theme.headlineSmall.copyWith(
              color: theme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: theme.bodySmall.copyWith(
                color: theme.contrast.withAlpha(178),
              ),
            ),
        ],
      ),
    );
  }
}
