import 'package:filmu_nams/assets/widgets/overlapping_carousel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _activeIndex = 0;

  final List<Map<String, String>> movieData = [
    {
      'title': 'Gladiators II',
      'description':
          'Leģendārā režisora Ridlija Skota jaunā filma "Gladiators II" turpina episko sāgu par spēku, intrigām un atriebību',
      'image':
          'https://forumcinemaslv.blob.core.windows.net/1012/Event_10533/portrait_medium/Gladiators-2-plakats-final.jpg?width=323',
    },
    {
      'title': 'Dune: Part Two',
      'description':
          'Turpinājums episkajam stāstam par Paula Atreida ceļojumu, kurā viņš apvienojas ar Čani un frēmeniem',
      'image':
          'https://m.media-amazon.com/images/M/MV5BNTc0YmQxMjEtODI5MC00NjFiLTlkMWUtOGQ5NjFmYWUyZGJhXkEyXkFqcGc@._V1_.jpg',
    },
    {
      'title': 'Poor Things',
      'description':
          'Jorgosa Lantimosa fantastikas filma par jaunu sievieti, kuru atdzīvina ekscentriskais zinātnieks',
      'image':
          'https://m.media-amazon.com/images/M/MV5BYWU2MjRjZTYtMjVkMS00MTBjLWFiMTAtYmZlYTk1YjkyMWFkXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
    },
    {
      'title': 'Kung Fu Panda 4',
      'description':
          'Po kļūst par Miera ielejas garīgo līderi un sastopas ar jaunu, bīstamu pretinieku',
      'image':
          'https://upload.wikimedia.org/wikipedia/en/7/7f/Kung_Fu_Panda_4_poster.jpg',
    },
    {
      'title': 'Lorem ipsum',
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'image':
          'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
    }
  ];

  late final List<Widget> carouselItems;

  @override
  void initState() {
    super.initState();
    carouselItems = List.generate(
      movieData.length,
      (index) => Builder(builder: (context) {
        final homeState = context.findAncestorStateOfType<_HomeState>();
        final isActive = homeState?._activeIndex == index;

        return MovieItem(index, isActive);
      }),
    );
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
      movieData[index]['description']!,
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
      movieData[index]['title']!,
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
        child: Image.network(movieData[index]['image']!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 240),
          OverlappingCarousel(
            items: carouselItems,
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
