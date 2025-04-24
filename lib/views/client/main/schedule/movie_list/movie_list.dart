import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/movie_model.dart';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _movieFetchSubscription;

  @override
  void dispose() {
    _movieFetchSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchMovies() async {
    _movieFetchSubscription = _firestore
        .collection('movies')
        .orderBy('premiere', descending: true)
        .snapshots()
        .listen((snapshot) async {
      final moviesDocs = snapshot.docs.map(
        (doc) => MovieModel.fromMap(doc.data(), doc.id),
      );

      setState(() {
        movieData = moviesDocs.toList();
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
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
