import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/widgets/overlapping_carousel.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../offers/offer_detail_view.dart';
import '../schedule/movie/movie_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CarouselItemModel>? carouselItems;
  List<Widget>? carouselWidgets;

  bool isLoading = true;
  int activeIndex = 0;

  final movieController = MovieController();

  void fetchCarouselItems() {
    movieController.getHomescreenCarousel()
    .then((response) {
      setState(() {
        carouselItems = response;
        carouselWidgets = List.generate(
          response.length,
          (index) => Builder(builder: (context) {
            final isActive = activeIndex == index;
            return MovieItem(index, isActive);
          }),
        );
      });
    })
    .catchError((error) {
      debugPrint(error.toString());
      if (mounted) {
        StylizedDialog.dialog(
            Icons.error_outline,
            context,
            "Kļūda",
            "Neizdevās dabūt datus"
        );
      }
    })
    .whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCarouselItems();
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
              borderRadius: BorderRadius.circular(15),
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
                margin: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carouselItems![index].title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      carouselItems![index].description,
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
      imageUrl: carouselItems![index].imageUrl,
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
    final theme = ContextTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          carouselWidgets!.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? theme.bodySmall.color
                  : theme.bodySmall.color!.withOpacity(0.3),
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

    if (carouselItems == null || carouselWidgets == null || carouselItems!.isEmpty) {
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

    final theme = ContextTheme.of(context);

    return Column(
      children: [
        SizedBox(height: 45),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sveicināti Filmu Namā 🎬',
              style: theme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Aplūko jaunākus piedāvājumus:\n(lai lasītu vairāk, pavelciet uz augšu ⬆️)',
              style: theme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 60),
        OverlappingCarousel(
          items: carouselWidgets!,
          itemWidth: 350,
          itemHeight: 480,
          scaleFactor: 0.70,
          horizontalSpace: 10,
          spacingFactor: 0.75,
          onPageChanged: (index) {
            setState(() {
              activeIndex = index;
            });
          },
          onVerticalScrollUp: (int swipedIndex) {
            if (carouselItems![swipedIndex].movie != null) {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MovieView(data: carouselItems![swipedIndex].movie!),
                  transitionsBuilder: getTransitionsBuilder(),
                ),
              );
            }

            if (carouselItems![swipedIndex].offer != null) {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      OfferView(data: carouselItems![swipedIndex].offer!),
                  transitionsBuilder: getTransitionsBuilder(),
                ),
              );
            }
          },
        ),
        dots(),
      ],
    );
  }

  getTransitionsBuilder() {
    return (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation, child: child,
      );
    };
  }
}
