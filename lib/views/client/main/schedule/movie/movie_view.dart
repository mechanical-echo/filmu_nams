import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/foldable_description.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/ticket_buying_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../providers/color_context.dart';

class MovieView extends StatefulWidget {
  const MovieView({
    super.key,
    required this.data,
  });

  final MovieModel data;

  static void show(BuildContext context, MovieModel data) {
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: Navigator.of(context),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      transitionAnimationController: animationController,
      builder: (context) => MovieView(data: data),
    );
  }

  @override
  State<MovieView> createState() => _MovieViewState();
}

class _MovieViewState extends State<MovieView> {
  String getDuration(int dur) => '${dur ~/ 60}h ${dur % 60}m';

  double headerHeight = 250;

  final double minHeaderHeight = 100;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void onScroll() {
    double offset = _scrollController.offset;

    /* Commented this out for now because it randomly throws an error 
      TODO: fix header crashing an app on scroll */

    setState(() {
      headerHeight = (250 - (offset * 0.5)).clamp(minHeaderHeight, 250);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final colors = ColorContext.of(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colors.color001,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      width: width,
      height: height * 0.82,
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: headerHeight,
            child: header(context),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                onScroll();
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  bottom: 35,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 15,
                      children: [
                        Expanded(child: title()),
                        badges(),
                      ],
                    ),
                    divider(colors),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Column(
                          spacing: 7,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              " Žanrs",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            badge(
                              GenreName[widget.data.genre]!,
                              TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          spacing: 7,
                          children: [
                            Text(
                              "Režisors",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            badge(widget.data.director, TextAlign.center),
                          ],
                        ),
                        Column(
                          spacing: 7,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Ilgums ",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            badge(
                              getDuration(widget.data.duration),
                              TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                    divider(colors),
                    FoldableDescription(data: widget.data),
                    divider(colors),
                    TicketBuyingForm(movieData: widget.data),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  badges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 5,
      children: List.generate(
        widget.data.actors.length,
        (index) => badge(widget.data.actors[index], TextAlign.right),
      ),
    );
  }

  Widget divider(ColorContext colors) {
    return Divider(
      color: colors.color003.withAlpha(100),
      thickness: 2,
      height: 32,
    );
  }

  badge(String text, TextAlign align) {
    final colors = ColorContext.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 15,
      ),
      width: 120,
      decoration: colors.classicDecorationSharper,
      child: Text(
        text,
        style: bodySmall,
        textAlign: align,
      ),
    );
  }

  Widget header(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: double.infinity,
          height: headerHeight,
          child: CachedNetworkImage(
            imageUrl: widget.data.heroUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 100,
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  double calculatePadding(double headerHeight) {
    double minHeight = 50;
    double maxHeight = 250;
    double startPadding = -105;
    double endPadding = 15;

    return startPadding +
        ((headerHeight - minHeight) / (maxHeight - minHeight)) *
            (endPadding - startPadding);
  }

  Container title() {
    final colors = ColorContext.of(context);
    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: colors.classicDecorationWhiteSharper,
      child: Center(
        child: Text(
          widget.data.title,
          style: widget.data.title.length > 14
              ? colors.header2ThemeColor
              : colors.header1ThemeColor,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
