import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/admin/item_card.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AdminMovieCard extends StatefulWidget {
  const AdminMovieCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final MovieModel data;
  final Function(String) onEdit;

  @override
  State<AdminMovieCard> createState() => _AdminMovieCardState();
}

class _AdminMovieCardState extends State<AdminMovieCard> {
  @override
  Widget build(BuildContext context) {
    return ItemCard(
      cardWidth: 396,
      leftContent: _buildPoster(),
      titleWidget: _buildTitle(),
      detailsWidget: _buildDetails(),
      actionButton: EditButton(
        onPressed: () => widget.onEdit(widget.data.id),
      ),
      topOverlay: Positioned(
        top: 10,
        right: 205,
        child: _buildRating(),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String getDuration() =>
      '${widget.data.duration ~/ 60}h ${widget.data.duration % 60}min';

  Widget _buildPoster() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          width: 190,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: CachedNetworkImage(
            imageUrl: widget.data.posterUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 100,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          )
        ],
        color: red002,
      ),
      child: Text(
        widget.data.rating,
        style: bodySmall.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildTitle() {
    return TextContainer(
      width: 206,
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

  Widget _buildDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDuration(),
        _buildGenre(),
        _buildDirector(),
      ],
    );
  }

  Widget _buildDuration() {
    return TextContainer(
      width: 206,
      color: red002,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          Text(getDuration(), style: bodySmall),
          const Icon(Icons.access_time, size: 15, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildGenre() {
    return TextContainer(
      width: 206,
      color: red002,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          Text(capitalize(widget.data.genre), style: bodySmall),
          const Icon(Icons.movie, size: 15, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildDirector() {
    return TextContainer(
      width: 206,
      color: red002,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          Text(widget.data.director, style: bodySmall),
          const Icon(Icons.person, size: 15, color: Colors.white),
        ],
      ),
    );
  }
}
