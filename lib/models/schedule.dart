import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ScheduleModel {
  final DateTime date;
  final List<ScheduleItem> movies;

  ScheduleModel({
    required this.date,
    required this.movies,
  });

  factory ScheduleModel.fromFirestore(QuerySnapshot snapshot, DateTime date) {
    List<ScheduleItem> scheduleItems = [];

    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final item = ScheduleItem.fromMap(data);
        scheduleItems.add(item);
      } catch (e) {
        debugPrint('Skipping invalid schedule item: $e');
        continue;
      }
    }

    return ScheduleModel(
      date: date,
      movies: scheduleItems,
    );
  }
}

class ScheduleItem {
  final DocumentReference? movie;
  final DateTime time;
  final int hall;

  ScheduleItem({
    this.movie,
    required this.time,
    required this.hall,
  });

  factory ScheduleItem.fromMap(Map<String, dynamic> map) {
    final movieIdValue = map['movieId'];
    DocumentReference? movieRef;

    if (movieIdValue != null) {
      if (movieIdValue is DocumentReference) {
        movieRef = movieIdValue;
      } else if (movieIdValue is String) {
        movieRef =
            FirebaseFirestore.instance.collection('movies').doc(movieIdValue);
      }
    }

    if (map['time'] == null) {
      throw FormatException('time is required in schedule item');
    }
    if (map['hall'] == null) {
      throw FormatException('hall is required in schedule item');
    }

    return ScheduleItem(
      movie: movieRef,
      time: (map['time'] as Timestamp).toDate(),
      hall: map['hall'] as int,
    );
  }
}
