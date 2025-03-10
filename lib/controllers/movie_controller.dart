import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/models/schedule.dart';

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

    return response.docs
        .map((doc) => MovieModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<MovieModel> getMovieById(String id) async {
    final response = await _firestore.collection('movies').doc(id).get();

    return MovieModel.fromMap(response.data()!, response.id);
  }

  Future<List<ScheduleModel>> getScheduleByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final startTimestamp = Timestamp.fromDate(startOfDay);
    final endTimestamp = Timestamp.fromDate(endOfDay);

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .where('time', isGreaterThanOrEqualTo: startTimestamp)
        .where('time', isLessThanOrEqualTo: endTimestamp)
        .get();

    return await convertQuerySnapshotToSchedule(querySnapshot);
  }

  Future<List<ScheduleModel>> getScheduleByMovie(MovieModel movie) async {
    DocumentReference movieRef = _firestore.collection('movies').doc(movie.id);

    final QuerySnapshot querySnapshot = await _firestore
        .collection('schedule')
        .where('movie', isEqualTo: movieRef)
        .get();

    return await convertQuerySnapshotToSchedule(querySnapshot);
  }

  Future<List<ScheduleModel>> getAllSchedule() async {
    final response = await _firestore.collection('schedule').get();
    final futures = response.docs.map((doc) => ScheduleModel.fromMapAsync(doc.data(), doc.id)).toList();
    return await Future.wait(futures);
  }

  Future<List<ScheduleModel>> convertQuerySnapshotToSchedule(
      QuerySnapshot qs) async {
    List<ScheduleModel> scheduleList = [];

    for (var doc in qs.docs) {
      final schedule =
          await ScheduleModel.fromMapAsync(doc.data() as Map<String, dynamic>, doc.id);
      scheduleList.add(schedule);
    }

    return scheduleList;
  }
}
