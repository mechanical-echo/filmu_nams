import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/models/carousel_item_model.dart';
import 'package:filmu_nams/providers/style.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_carousel_items/edit_carousel_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CarouselItemCard extends StatefulWidget {
  const CarouselItemCard({
    super.key,
    required this.data,
  });

  final CarouselItemModel data;

  @override
  State<CarouselItemCard> createState() => _CarouselItemCardState();
}

class _CarouselItemCardState extends State<CarouselItemCard> {
  bool isHovered = false;

  Style get theme => Style.of(context);

  void showEditForm() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditCarouselItemDialog(data: widget.data);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Card(
        margin: const EdgeInsets.only(bottom: 0),
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: InkWell(
          onTap: showEditForm,
          child: Container(
            decoration:
                isHovered ? theme.activeCardDecoration : theme.cardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCarouselImage(),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildContentInfo(),
                  ),
                  const SizedBox(width: 16),
                  _buildLinkSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselImage() {
    return Hero(
      tag: 'carousel-image-${widget.data.id}',
      child: Container(
        width: 120,
        height: 85,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CachedNetworkImage(
          imageUrl: widget.data.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: theme.primary,
              size: 30,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child:
                Icon(Icons.image_not_supported, color: theme.primary, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.title,
          style: theme.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
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

  Widget _buildLinkSection() {
    if (widget.data.movie == null && widget.data.offer == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off,
                size: 16, color: theme.contrast.withAlpha(125)),
            const SizedBox(width: 4),
            Text(
              'Nav saites',
              style: theme.bodySmall
                  .copyWith(color: theme.contrast.withAlpha(178)),
            ),
          ],
        ),
      );
    }

    if (widget.data.movie != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primary.withAlpha(76)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.movie, size: 16, color: theme.primary),
                const SizedBox(width: 4),
                Text(
                  'Filma',
                  style: theme.labelMedium.copyWith(color: theme.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.movie!.title,
              style: theme.bodySmall.copyWith(
                color: theme.contrast.withAlpha(178),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    if (widget.data.offer != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.secondary.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.secondary.withAlpha(76)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.percent, size: 16, color: theme.secondary),
                const SizedBox(width: 4),
                Text(
                  'Piedāvājums',
                  style: theme.labelMedium.copyWith(color: theme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.offer!.title,
              style: theme.bodySmall.copyWith(
                color: theme.contrast.withAlpha(178),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
