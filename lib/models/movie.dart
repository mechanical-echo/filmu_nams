import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final int duration;
  final String rating;
  final String genre;
  final String director;
  final String heroUrl;
  final Timestamp premiere;
  final List<dynamic> actors;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.duration,
    required this.rating,
    required this.genre,
    required this.director,
    required this.heroUrl,
    required this.actors,
    required this.premiere,
  });

  factory MovieModel.fromMap(Map<String, dynamic> map, String id) {
    return MovieModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      posterUrl: map['poster-url'] ?? '',
      duration: map['duration'] ?? 0,
      rating: map['rating'] ?? '',
      genre: map['genre'] ?? '',
      director: map['director'] ?? '',
      heroUrl: map['hero-url'] ?? '',
      actors: map['actors'] ?? '',
      premiere: map['premiere'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster-url': posterUrl,
      'duration': duration,
      'rating': rating,
      'genre': genre,
      'director': director,
      'hero-url': heroUrl,
      'actors': actors,
      'premiere': premiere,
    };
  }
}

Map<String, String> GenreName = {
  "adventure": "Piedzīvojums",
  "animation": "Animācija",
};
