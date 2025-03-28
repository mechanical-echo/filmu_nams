import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/overlapping_carousel.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _activeIndex = 0;
  List<CarouselItemModel>? movieData;
  List<Widget>? carouselItems;
  bool isLoading = true;

  Future<void> fetchHomescreenCarouselFromFirebase() async {
    try {
      final response = await MovieController().getHomescreenCarousel();

      setState(() {
        movieData = response;
        carouselItems = List.generate(
          response.length,
          (index) => Builder(builder: (context) {
            final homeState = context.findAncestorStateOfType<_HomeState>();
            final isActive = homeState?._activeIndex == index;

            return MovieItem(index, isActive);
          }),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching movies: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHomescreenCarouselFromFirebase();
  }

  MovieItem(int index, bool isActive) {
    return Container(
      clipBehavior: Clip.none,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          if (isActive)
            Positioned(
              top: 420,
              child: MovieItemDescription(index),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: 2),
            child: image(index),
          ),
          if (isActive)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: MovieItemTitle(index),
            ),
        ],
      ),
    );
  }

  CachedNetworkImage image(int index) {
    return CachedNetworkImage(
      imageUrl: movieData![index].imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[800],
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            size: 50,
            color: Theme.of(context).focusColor,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_rounded,
                color: Colors.white70,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Attēlu neizdevās ielādēt',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget MovieItemDescription(int index) {
    final colors = ColorContext.of(context);
    return Container(
      decoration: colors.classicDecorationWhiteSharper,
      padding: const EdgeInsets.all(15),
      constraints: BoxConstraints(
        minHeight: 150,
      ),
      width: 450,
      child: Center(
        child: Text(
          movieData![index].description,
          style: colors.bodyMediumThemeColor,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget MovieItemTitle(int index) {
    final colors = ColorContext.of(context);
    return Center(
      child: FittedBox(
        fit: BoxFit.none,
        child: Container(
          width: 320,
          decoration: colors.classicDecorationDarkSharper,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Center(
            child: Text(
              movieData![index].title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  dots() {
    final colors = ColorContext.of(context);
    return IntrinsicWidth(
      child: Container(
        decoration: colors.classicDecorationSharp,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                List.generate(carouselItems!.length, (index) => dot(index))),
      ),
    );
  }

  dot(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: index == _activeIndex ? Colors.white : Colors.white30,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          size: 100,
          color: Theme.of(context).focusColor,
        ),
      );
    }

    if (movieData == null || carouselItems == null || movieData!.isEmpty) {
      return const Center(
        child: Text('Nav datu, lai attēlotu'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 165, bottom: 250),
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 25,
      children: [
        dots(),
        OverlappingCarousel(
          items: carouselItems!,
          itemWidth: 350,
          itemHeight: 400,
          scaleFactor: 0.95,
          horizontalSpace: 10,
          spacingFactor: 0.75,
          onPageChanged: (index) {
            setState(() {
              _activeIndex = index;
            });
          },
        ),
        SizedBox(height: 80),
      ],
    ));
  }
}
