import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/widgets/overlapping_carousel.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/carousel_item_model.dart';
import 'package:filmu_nams/providers/style.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _carouselSubscription;

  List<CarouselItemModel>? carouselItems;
  List<Widget>? carouselWidgets;

  bool isLoading = true;
  int activeIndex = 0;

  final movieController = MovieController();

  Style get theme => Style.of(context);

  void listenToCarouselChanges() {
    _carouselSubscription = _firestore
        .collection(MovieController.carouselCollection)
        .snapshots()
        .listen((snapshot) async {
      final futures = snapshot.docs.map(
        (doc) => CarouselItemModel.fromMapAsync(doc.data(), doc.id),
      );

      final items = await Future.wait(futures.toList());

      setState(() {
        carouselItems = items;
        carouselWidgets = List.generate(
          items.length,
          (index) => Builder(builder: (context) {
            final isActive = activeIndex == index;
            return MovieItem(index, isActive);
          }),
        );
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to carousel changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    listenToCarouselChanges();
  }

  @override
  void dispose() {
    _carouselSubscription?.cancel();
    super.dispose();
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
          if (carouselItems![index].movie != null ||
              carouselItems![index].offer != null)
            Positioned(
              top: -25,
              left: 25,
              right: 25,
              child: Text(
                '(lai lasītu vairāk, pavelciet uz augšu ⬆️)',
                style: theme.titleSmall,
              ),
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
                      Colors.black.withAlpha(240),
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
                        color: Colors.white.withAlpha(229),
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
    final theme = Style.of(context);
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
                  : theme.bodySmall.color!.withAlpha(76),
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

    if (carouselItems == null ||
        carouselWidgets == null ||
        carouselItems!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie,
              size: 64,
              color: Colors.white.withAlpha(125),
            ),
            const SizedBox(height: 16),
            Text(
              'Nav datu, lai attēlotu',
              style: TextStyle(
                color: Colors.white.withAlpha(125),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final theme = Style.of(context);
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: 35),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sveicināti Filmu Namā 🎬',
              style: theme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Aplūko jaunākus piedāvājumus:',
              style: theme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 70),
        OverlappingCarousel(
          items: carouselWidgets!,
          itemWidth: 350,
          itemHeight: height * 0.49,
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
        position: offsetAnimation,
        child: child,
      );
    };
  }
}
