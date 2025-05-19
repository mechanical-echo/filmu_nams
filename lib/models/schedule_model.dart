import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:intl/intl.dart';

class ScheduleModel {
  final String id;
  final MovieModel movie;
  final int hall;
  final Timestamp time;

  ScheduleModel({
    required this.id,
    required this.movie,
    required this.hall,
    required this.time,
  });

  factory ScheduleModel.fromMap(
      Map<String, dynamic> map, MovieModel movie, String id) {
    return ScheduleModel(
      id: id,
      movie: movie,
      hall: map['hall'] ?? 0,
      time: map['time'] ?? Timestamp.now(),
    );
  }

  static Future<ScheduleModel> fromMapAsync(
      Map<String, dynamic> map, String id) async {
    final movieSnapshot = await map['movie'].get();
    final movie = MovieModel.fromMap(movieSnapshot.data(), movieSnapshot.id);

    return ScheduleModel.fromMap(map, movie, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movie': movie,
      'hall': hall,
      'time': time,
    };
  }

  String getFormattedTime() {
    return DateFormat(DateFormat.HOUR24_MINUTE).format(time.toDate());
  }

  String getFormattedDate() {
    return DateFormat(DateFormat.YEAR_MONTH_DAY).format(time.toDate());
  }
}
