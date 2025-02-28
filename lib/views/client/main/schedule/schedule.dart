import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/views/client/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 170.0, bottom: 105),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StylizedTabs(
              tabs: [
                StylizedTabPage(
                  title: 'Saraksts',
                  child: Container(
                    width: 300,
                    height: 300,
                    color: Colors.red,
                  ),
                ),
                StylizedTabPage(
                  title: 'Visas filmas',
                  child: MovieList(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MovieList extends StatefulWidget {
  const MovieList({
    super.key,
  });

  @override
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<Map<String, String>>? movieData;
  bool isLoading = true;

  Future<void> fetchHomescreenCarouselFromFirebase() async {
    try {
      final response = await MovieController().getAllMovies();
      final movies = response
          .map((item) =>
              item.map((key, value) => MapEntry(key, value.toString())))
          .toList();

      setState(() {
        movieData = movies;
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 325,
      child: GridView.count(
        padding:
            const EdgeInsets.only(top: 20, bottom: 70, left: 10, right: 10),
        crossAxisCount: 1,
        childAspectRatio: 1.5,
        mainAxisSpacing: 10,
        children: movieData != null
            ? List.generate(
                movieData!.length,
                (index) => MovieCard(data: movieData![index]),
              )
            : [
                Loading(),
              ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.data,
  });

  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(5, 0),
              ),
            ]),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                poster(),
                rating(context),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title(context),
                description(context),
                button(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container button(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(80),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ]),
      child: Center(
        child: FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(0),
            backgroundColor: Theme.of(context).focusColor,
            fixedSize: Size(200, 30),
          ),
          child: Text(
            "Vairāk",
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Container poster() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      decoration: BoxDecoration(),
      child: CachedNetworkImage(
        imageUrl: data['poster-url']!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 100,
          ),
        ),
      ),
    );
  }

  Container rating(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          )
        ],
        color: Theme.of(context).focusColor,
      ),
      child: Text(
        data['rating']!,
      ),
    );
  }

  Container description(BuildContext context) {
    return Container(
      height: 125,
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).focusColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 7),
            ),
          ]),
      child: Text(
        data['description']!,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Container title(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).focusColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 7),
            ),
          ]),
      child: Text(
        data['title']!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
