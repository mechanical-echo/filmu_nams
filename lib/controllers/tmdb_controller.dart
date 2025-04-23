import 'package:filmu_nams/tmdb.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TmdbController {
  final tmdbWithCustomLogs = TMDB(
    ApiKeys(
      tmdbApiKey,
      tmdbReadAccess,
    ),
    defaultLanguage: 'lv-LV',
  );

  Future<dynamic> getMovieDetails(int movieId) async {
    try {
      final movieDetails =
          await tmdbWithCustomLogs.v3.movies.getDetails(movieId);
      return movieDetails;
    } catch (e) {
      print('Error fetching movie details: $e');
      return [];
    }
  }

  Future<Map<dynamic, dynamic>> discoverMovies({int page = 1}) {
    return tmdbWithCustomLogs.v3.discover.getMovies(page: page);
  }

  Future<Map<dynamic, dynamic>> searchMovies(String query,
      {int page = 1}) async {
    debugPrint('Searching for movies with query: $query');
    return tmdbWithCustomLogs.v3.search
        .queryMovies(query, language: 'lv-LV', page: page);
  }
}
