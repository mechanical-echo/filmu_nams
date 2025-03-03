import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MovieList extends StatefulWidget {
  const MovieList({
    super.key,
  });

  @override
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<MovieModel>? movieData;
  bool isLoading = true;

  Future<void> fetchMovies() async {
    try {
      final response = await MovieController().getAllMovies();
      setState(() {
        movieData = response;
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
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 325,
      child: isLoading
          ? LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white, size: 100)
          : GridView.count(
              padding: const EdgeInsets.only(top: 10, bottom: 70),
              crossAxisCount: 1,
              childAspectRatio: 1.5,
              mainAxisSpacing: 10,
              children: List.generate(
                movieData!.length,
                (index) => MovieCard(data: movieData![index]),
              ),
            ),
    );
  }
}

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.data,
  });

  final MovieModel data;

  @override
  Widget build(BuildContext context) {
    final double topMargin = data.title.length > 12 ? 88 : 75;
    final double bottomMargin = data.title.length > 12 ? 63 : 70;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 180,
                margin: EdgeInsets.only(
                  bottom: bottomMargin,
                  top: topMargin,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 10,
                right: -10,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: title(),
                    ),
                    duration(),
                    genre(),
                    director(),
                  ],
                ),
              ),
              Positioned(
                bottom: 5,
                left: -10,
                right: 0,
                child: button(),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(150),
                  blurRadius: 15,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                poster(),
                rating(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  String getDuration() => '${data.duration ~/ 60}h ${data.duration % 60}min';

  Container poster() {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: data.posterUrl,
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
        color: red002,
      ),
      child: Text(
        data.rating,
      ),
    );
  }

  title() {
    return TextContainer(
      Text(
        data.title,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: red002,
          fontSize: data.title.length > 12 ? 17 : 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      smokeyWhite,
    );
  }

  duration() {
    return TextContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Text(getDuration(), style: bodyMedium),
          Icon(Icons.access_time, size: 15, color: Colors.white),
        ],
      ),
      red002,
    );
  }

  genre() {
    return TextContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Text(capitalize(data.genre), style: bodyMedium),
          Icon(Icons.movie, size: 15, color: Colors.white),
        ],
      ),
      red002,
    );
  }

  director() {
    return TextContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Text(data.director, style: bodyMedium),
          Icon(Icons.person, size: 15, color: Colors.white),
        ],
      ),
      red002,
    );
  }

  button() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: red002,
          fixedSize: Size(108, 10),
        ),
        child: Text("Vairāk", style: bodyLarge),
      ),
    );
  }

  TextContainer(text, Color color) {
    return Container(
      width: 206,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: text,
    );
  }
}
