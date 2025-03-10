import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/foldable_description.dart';
import 'package:filmu_nams/views/client/main/schedule/movie/ticket_buying_form.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MovieView extends StatelessWidget {
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

  String getDuration(int dur) => '${dur ~/ 60}h ${dur % 60}m';
  String formatTitle(String s) => s.replaceFirst(':', ':\n');

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: red001,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      width: width,
      height: height * 0.82,
      child: Column(
        children: [
          header(width, context),
          SizedBox(
            height: height * 0.5,
            child: SingleChildScrollView(
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
                        spacing: 5.0,
                        children: List.generate(
                          data.actors.length,
                          (index) => badge(data.actors[index]),
                        ),
                      ),
                    ),
                  ),
                  FoldableDescription(data: data),
                  TicketBuyingForm(movieData: data)
                ],
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
        style: bodyMedium,
      ),
    );
  }

  SizedBox header(double width, BuildContext context) {
    return SizedBox(
      width: width,
      height: 250,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(190),
                  blurRadius: 25,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: data.heroUrl,
              placeholder: (context, url) =>
                  LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 100,
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
            bottom: 15,
            child: Container(
              clipBehavior: Clip.none,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  badge(GenreName[data.genre]!),
                  badge(data.director),
                  badge(getDuration(data.duration)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        formatTitle(data.title),
        style: bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
