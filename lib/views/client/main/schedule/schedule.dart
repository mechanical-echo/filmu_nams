import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/widgets/stylized_tabs/stylized_tabs.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/views/client/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
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
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: 165,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                data['title']!,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 10,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            height: 250,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(225),
                  blurRadius: 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: data['poster-url']!,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
            ),
          ),
        )
      ],
    );
  }
}
