import 'package:cached_network_image/cached_network_image.dart';
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
    return Column(
      children: [
        movieItemContent(index),
        // if (isActive) movieItemText(index), //TODO rework the way description shows
      ],
    );
  }

  Positioned movieItemText(int index) {
    return Positioned(
      top: 340,
      child: Column(
        spacing: 10,
        children: [
          MovieItemTitle(index),
          MovieItemDescription(index),
        ],
      ),
    );
  }

  MovieItemDescription(int index) {
    return SizedBox(
      width: 300,
      child: Text(
        movieData![index].description,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 158, 158, 158),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  MovieItemTitle(int index) {
    final colors = ColorContext.of(context);
    return Container(
      decoration: colors.classicDecorationWhite,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Text(
        movieData![index].title,
        style: colors.header2ThemeColor,
        textAlign: TextAlign.center,
      ),
    );
  }

  Container movieItemContent(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      width: 190,
      height: 300,
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: movieData![index].imageUrl,
        fit: BoxFit.fill,
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
          child: const Icon(Icons.error, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
        child: Text('No movies available'),
      );
    }

    final colors = ColorContext.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 240),
        child: OverlappingCarousel(
          items: carouselItems!,
          itemWidth: 190,
          itemHeight: 300,
          scaleFactor: 0.85,
          horizontalSpace: 10,
          spacingFactor: 0.75,
          onPageChanged: (index) {
            setState(() {
              _activeIndex = index;
            });
          },
        ),
    );
  }
}
