import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/foldable_description.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/ticket_buying_form.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  String formatTitle(String s) => s.replaceFirst(':', ':\n');

  double headerHeight = 250;

  final double minHeaderHeight = 100;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset;

    /* Commented this out for now because it randomly throws an error 
      TODO: fix header crashing an app on scroll */

    // setState(() {
    //   headerHeight = (250 - (offset * 0.5)).clamp(minHeaderHeight, 250);
    // });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: red001,
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
                _onScroll();
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 35, top: 10),
                child: Column(
                  children: [
                    title(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 4,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 15,
                          children: List.generate(
                            widget.data.actors.length,
                            (index) => badge(widget.data.actors[index]),
                          ),
                        ),
                      ),
                    ),
                    FoldableDescription(data: widget.data),
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

  Container badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
        horizontal: 15,
      ),
      decoration: classicDecorationSharper,
      child: Text(
        text,
        style: bodySmall,
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
        Positioned(
          bottom: calculatePadding(headerHeight),
          child: Container(
            clipBehavior: Clip.none,
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                badge(GenreName[widget.data.genre]!),
                badge(widget.data.director),
                badge(getDuration(widget.data.duration)),
              ],
            ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: bottomBorder,
        boxShadow: cardShadow,
        color: red002,
      ),
      child: Text(
        formatTitle(widget.data.title),
        style: bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
