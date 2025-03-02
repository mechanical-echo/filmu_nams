class MovieModel {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final int duration;
  final String rating;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.duration,
    required this.rating,
  });

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      posterUrl: map['poster-url'] ?? '',
      duration: map['duration'] ?? 0,
      rating: map['rating'] ?? '',
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
    };
  }
}
