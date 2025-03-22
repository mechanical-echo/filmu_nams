import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/admin/item_card.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScheduleCard extends StatefulWidget {
  const ScheduleCard({
    super.key,
    required this.data,
    required this.onEdit,
  });

  final ScheduleModel data;
  final Function(String) onEdit;

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  @override
  Widget build(BuildContext context) {
    return ItemCard(
      cardWidth: 390,
      leftContent: _buildPoster(),
      titleWidget: _buildTitle(),
      detailsWidget: _buildDetails(),
      actionButton: EditButton(
        onPressed: () => widget.onEdit(widget.data.id),
      ),
      topOverlay: _buildShowtime(),
    );
  }

  Widget _buildPoster() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: widget.data.movie.posterUrl,
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
      width: 200,
      color: smokeyWhite,
      child: Text(
        widget.data.movie.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: red002,
          fontSize: widget.data.movie.title.length > 12 ? 17 : 25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDetailRow(
          getDuration(),
          Icons.access_time,
        ),
        _buildDetailRow(
          capitalize(widget.data.movie.genre),
          Icons.movie,
        ),
        _buildDetailRow(
          widget.data.movie.director,
          Icons.person,
        ),
        _buildDetailRow(
          "Hall ${widget.data.hall}",
          Icons.chair,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String text, IconData icon) {
    return TextContainer(
      width: 200,
      color: red002,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, size: 18, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildShowtime() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: red002,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          DateFormat('HH:mm').format(widget.data.time.toDate()),
          style: bodyMedium,
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String getDuration() =>
      '${widget.data.movie.duration ~/ 60}h ${widget.data.movie.duration % 60}min';
}
