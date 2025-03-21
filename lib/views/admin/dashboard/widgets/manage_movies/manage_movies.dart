import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/movie_controller.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/admin_movie_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageMovies extends StatefulWidget {
  const ManageMovies({
    super.key,
    required this.action,
  });

  final Function(int, String) action;

  @override
  State<ManageMovies> createState() => _ManageMoviesState();
}

class _ManageMoviesState extends State<ManageMovies> {
  List<MovieModel>? movies;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHomescreenCarouselFromFirebase();
  }

  Future<void> fetchHomescreenCarouselFromFirebase() async {
    try {
      final response = await MovieController().getAllMovies();
      setState(() {
        movies = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching carousel items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: smokeyWhite, size: 100),
          )
        : ManageScreen(
            count: movies!.length,
            isLoading: isLoading,
            itemGenerator: generateCards(),
            title: "Filmas",
          );
  }

  generateCards() {
    return (index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: classicDecorationSharp,
          child: AdminMovieCard(
            data: movies![index],
            onEdit: (itemId) {
              widget.action(10, itemId);
            },
          ),
        );
  }
}
