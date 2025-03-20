import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/carousel_item.dart';
import 'package:filmu_nams/models/movie.dart';
import 'package:filmu_nams/models/schedule.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MovieController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String carouselCollection = 'homescreen-carousel';

  Future<List<CarouselItemModel>> getHomescreenCarousel() async {
    final response = await _firestore.collection(carouselCollection).get();

    return response.docs
        .map((doc) => CarouselItemModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<CarouselItemModel> getCarouselItemById(String id) async {
    final response =
        await _firestore.collection(carouselCollection).doc(id).get();

    return CarouselItemModel.fromMap(response.data()!, response.id);
  }

  Future<void> updateHomescreenCarousel(
    String id,
    String title,
    String description,
    Uint8List? image,
    String? url,
  ) async {
    String? uploadResult;
    if (image != null) {
      uploadResult = await uploadCoverImage(id, image);
    }

    await _firestore.collection(carouselCollection).doc(id).update({
      'title': title,
      'description': description,
      'image-url': url ?? uploadResult,
    });
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
    final futures = response.docs
        .map((doc) => ScheduleModel.fromMapAsync(doc.data(), doc.id))
        .toList();
    return await Future.wait(futures);
  }

  Future<List<ScheduleModel>> convertQuerySnapshotToSchedule(
      QuerySnapshot qs) async {
    List<ScheduleModel> scheduleList = [];

    for (var doc in qs.docs) {
      final schedule = await ScheduleModel.fromMapAsync(
          doc.data() as Map<String, dynamic>, doc.id);
      scheduleList.add(schedule);
    }

    return scheduleList;
  }

  Future<String?> uploadCoverImage(
    String userId,
    Uint8List imageFileWeb,
  ) async {
    try {
      Reference reference = _storage.ref().child('carousel_covers/$userId.jpg');

      UploadTask uploadTask = reference.putData(imageFileWeb);

      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }
}
