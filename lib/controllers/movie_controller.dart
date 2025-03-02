import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:flutter/foundation.dart';

class MovieController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CarouselItemModel>> getHomescreenCarousel() async {
    final response = await _firestore.collection('homescreen-carousel').get();

    return response.docs
        .map((doc) => CarouselItemModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<MovieModel>> getAllMovies() async {
    final response = await _firestore.collection('movies').get();

    return response.docs.map((doc) => MovieModel.fromMap(doc.data())).toList();
  }

  Future<MovieModel> getMovieById(String id) async {
    final response = await _firestore.collection('movies').doc(id).get();

    return MovieModel.fromMap(response.data()!);
  }

  Future<ScheduleModel> getSchedule(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .where('time', isGreaterThanOrEqualTo: startTimestamp)
        .where('time', isLessThanOrEqualTo: endTimestamp)
        .get();

    for (var doc in querySnapshot.docs) {
      debugPrint('Schedule document data: ${doc.data()}');
    }

    return ScheduleModel.fromFirestore(querySnapshot, date);
  }
}
