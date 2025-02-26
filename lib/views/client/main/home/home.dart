import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/widgets/overlapping_carousel.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
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
  List<Map<String, String>>? movieData;
  List<Widget>? carouselItems;
  bool isLoading = true;

  Future<void> fetchHomescreenCarouselFromFirebase() async {
    try {
      final response = await MovieController().getHomescreenCarousel();
      final movies = response
          .map((item) =>
              item.map((key, value) => MapEntry(key, value.toString())))
          .toList();

      setState(() {
        movieData = movies;
        carouselItems = List.generate(
          movies.length,
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
      // Handle error appropriately
      debugPrint('Error fetching movies: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHomescreenCarouselFromFirebase();
  }

  Stack MovieItem(int index, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        MovieItemContent(index),
        if (isActive) MovieItemText(index),
      ],
    );
  }

  Positioned MovieItemText(int index) {
    return Positioned(
      bottom: -170,
      left: -25,
      right: -25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MovieItemTitle(index),
          const SizedBox(height: 10),
          MovieItemDescription(index),
        ],
      ),
    );
  }

  Text MovieItemDescription(int index) {
    return Text(
      movieData![index]['description']!,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 158, 158, 158),
      ),
      textAlign: TextAlign.center,
    );
  }

  Text MovieItemTitle(int index) {
    return Text(
      movieData![index]['title']!,
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Container MovieItemContent(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: CachedNetworkImage(
            imageUrl: movieData![index]['image-url']!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[800],
              child: Center(
                child: LoadingAnimationWidget.stretchedDots(
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
        child: LoadingAnimationWidget.stretchedDots(
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

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 240),
          OverlappingCarousel(
            items: carouselItems!,
            itemWidth: width * 0.55,
            itemHeight: height * 0.33,
            scaleFactor: 0.85,
            horizontalSpace: 10,
            spacingFactor: 0.75,
            onPageChanged: (index) {
              setState(() {
                _activeIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
