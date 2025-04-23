import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/admin_movie_card.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_movies/edit_movie_dialog.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/manage_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageMovies extends StatefulWidget {
  const ManageMovies({
    super.key,
  });

  @override
  State<ManageMovies> createState() => _ManageMoviesState();
}

class _ManageMoviesState extends State<ManageMovies> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<MovieModel>? movies;
  bool isLoading = true;

  ContextTheme get theme => ContextTheme.of(context);

  StreamSubscription<QuerySnapshot>? _movieFetchSubscription;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  void dispose() {
    _movieFetchSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchMovies() async {
    _movieFetchSubscription =
        _firestore.collection('movies').snapshots().listen((snapshot) async {
      final moviesDocs = snapshot.docs.map(
        (doc) => MovieModel.fromMap(doc.data(), doc.id),
      );

      setState(() {
        movies = moviesDocs.toList();
        isLoading = false;
      });
    }, onError: (e) {
      debugPrint('Error listening to carousel changes: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  void showAddDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditMovieDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
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
            onCreate: () => showAddDialog(),
          );
  }

  generateCards() {
    return (index) => AdminMovieCard(
          data: movies![index],
        );
  }
}
