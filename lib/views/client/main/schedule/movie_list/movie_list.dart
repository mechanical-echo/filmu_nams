import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list/movie_card.dart';
import 'package:flutter/material.dart';
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
