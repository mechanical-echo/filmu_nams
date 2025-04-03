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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: image(index),
          ),
          if (isActive) ...[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movieData![index].title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movieData![index].description,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  dots() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          carouselItems!.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == _activeIndex
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nav datu, lai attēlotu',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sveicināti Filmā Nams',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atrastie jaunākie filmu piedāvājumi',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          dots(),
          const SizedBox(height: 16),
          OverlappingCarousel(
            items: carouselItems!,
            itemWidth: 350,
            itemHeight: 500,
            scaleFactor: 0.95,
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
