import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/movie_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../providers/color_context.dart';

class MovieCard extends StatefulWidget {
  const MovieCard({
    super.key,
    required this.data,
    this.time,
    this.hall,
  });

  final MovieModel data;
  final DateTime? time;
  final int? hall;

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  void openMovieView() {
    setState(() {
      MovieView.show(context, widget.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double topMargin = widget.data.title.length > 12 ? 88 : 75;
    final double bottomMargin = widget.data.title.length > 12 ? 63 : 70;
    final colors = ColorContext.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 180,
                margin: EdgeInsets.only(
                  bottom: bottomMargin,
                  top: topMargin,
                ),
                decoration: BoxDecoration(
                  color: colors.color001,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 10,
                right: -10,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: title(),
                    ),
                    duration(),
                    genre(),
                    director(),
                  ],
                ),
              ),
              Positioned(
                bottom: 5,
                left: -10,
                right: 0,
                child: button(),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(150),
                  blurRadius: 15,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                poster(),
                rating(context),
                if (widget.time != null) scheduledTime(context)
              ],
            ),
          )
        ],
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String getDuration() =>
      '${widget.data.duration ~/ 60}h ${widget.data.duration % 60}min';

  String getTime() =>
      intl.DateFormat(intl.DateFormat.HOUR24_MINUTE).format(widget.time!);

  Container poster() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
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
    );
  }

  Container rating(BuildContext context) {
    final colors = ColorContext.of(context);
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
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
        color: colors.color002,
      ),
      child: Text(
        widget.data.rating,
      ),
    );
  }

  scheduledTime(BuildContext context) {
    final colors = ColorContext.of(context);
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(250),
              blurRadius: 15,
              offset: const Offset(5, 5),
            )
          ],
          color: colors.color002,
        ),
        child: Text(
          '${getTime()}  -  ${widget.hall}. Zāle',
        ),
      ),
    );
  }

  title() {
    final colors = ColorContext.of(context);
    return TextContainer(
      Text(
        widget.data.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: colors.color002,
          fontSize: widget.data.title.length > 12 ? 17 : 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      smokeyWhite,
    );
  }

  duration() {
    final colors = ColorContext.of(context);
    return TextContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Text(getDuration(), style: bodySmall),
          Icon(Icons.access_time, size: 15, color: Colors.white),
        ],
      ),
      colors.color002,
    );
  }

  genre() {
    final colors = ColorContext.of(context);
    return TextContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Text(capitalize(widget.data.genre), style: bodySmall),
          Icon(Icons.movie, size: 15, color: Colors.white),
        ],
      ),
      colors.color002,
    );
  }

  director() {
    final colors = ColorContext.of(context);
    return TextContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Text(widget.data.director, style: bodySmall),
          Icon(Icons.person, size: 15, color: Colors.white),
        ],
      ),
      colors.color002,
    );
  }

  button() {
    final colors = ColorContext.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: openMovieView,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: colors.color002,
          fixedSize: Size(108, 10),
        ),
        child: Text(widget.time != null ? "Nopirkt biļeti" : "Vairāk",
            style: bodyLarge),
      ),
    );
  }

  TextContainer(text, Color color) {
    return Container(
      width: 206,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: text,
    );
  }
}
