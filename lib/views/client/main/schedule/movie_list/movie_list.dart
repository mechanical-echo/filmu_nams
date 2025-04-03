import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/client/main/schedule/movie_list/movie_card.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visas filmas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Atrastie visi pieejamie filmu piedāvājumi',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 100,
                  ),
                )
              : movieData == null || movieData!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_filter_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nav pieejamu filmu',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: movieData!.length,
                      itemBuilder: (context, index) => MovieCard(
                        data: movieData![index],
                      ),
                    ),
        ),
      ],
    );
  }
}
