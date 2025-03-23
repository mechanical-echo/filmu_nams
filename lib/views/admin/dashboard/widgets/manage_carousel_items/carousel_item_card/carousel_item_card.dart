import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/admin/item_card.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CarouselItemCard extends StatefulWidget {
  const CarouselItemCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final CarouselItemModel data;
  final Function(String) onEdit;

  @override
  State<CarouselItemCard> createState() => _CarouselItemCardState();
}

class _CarouselItemCardState extends State<CarouselItemCard> {
  @override
  Widget build(BuildContext context) {
    return ItemCard(
      cardWidth: 365,
      leftContent: _buildPoster(),
      titleWidget: _buildTitle(),
      detailsWidget: _buildDescription(),
      actionButton: EditButton(
        onPressed: () => widget.onEdit(widget.data.id),
      ),
    );
  }

  Widget _buildPoster() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: widget.data.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 100,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return TextContainer(
      width: 175,
      color: smokeyWhite,
      child: Text(
        widget.data.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: red002,
          fontSize: widget.data.title.length > 12 ? 17 : 25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return TextContainer(
      width: 175,
      color: smokeyWhite,
      child: Text(
        widget.data.description,
        style: bodyMediumRed,
        maxLines: widget.data.title.length > 14 ? 4 : 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
