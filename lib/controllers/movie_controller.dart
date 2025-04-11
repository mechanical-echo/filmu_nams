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

    final futures = response.docs
        .map((doc) => CarouselItemModel.fromMapAsync(doc.data(), doc.id))
        .toList();
    return await Future.wait(futures);
  }

  Future<CarouselItemModel> getCarouselItemById(String id) async {
    final response = await _firestore.collection(carouselCollection).doc(id).get();

    return await CarouselItemModel.fromMapAsync(response.data()!, response.id);
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

  Future<void> updateMovie(
    String id,
    String title,
    String description,
    String director,
    String genre,
    String rating,
    int duration,
    List<String> actors,
    Uint8List? posterImage,
    Uint8List? heroImage,
    String? posterUrl,
    String? heroUrl,
  ) async {
    String? uploadedPosterUrl;
    String? uploadedHeroUrl;

    if (posterImage != null) {
      uploadedPosterUrl = await uploadMovieImage(id, posterImage, 'poster');
    }

    if (heroImage != null) {
      uploadedHeroUrl = await uploadMovieImage(id, heroImage, 'hero');
    }

    await _firestore.collection('movies').doc(id).update({
      'title': title,
      'description': description,
      'director': director,
      'genre': genre,
      'rating': rating,
      'duration': duration,
      'actors': actors,
      'poster-url': posterUrl ?? uploadedPosterUrl ?? '',
      'hero-url': heroUrl ?? uploadedHeroUrl ?? '',
    });
  }

  Future<void> deleteMovie(String id) async {
    try {
      DocumentReference movieRef = _firestore.collection('movies').doc(id);
      QuerySnapshot scheduleQuery = await _firestore
          .collection('schedule')
          .where('movie', isEqualTo: movieRef)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in scheduleQuery.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(movieRef);

      await batch.commit();

      try {
        await _storage.ref().child('movie_posters/$id.jpg').delete();
        await _storage.ref().child('movie_heroes/$id.jpg').delete();
      } catch (e) {
        debugPrint('Error deleting movie images: $e');
      }
    } catch (e) {
      debugPrint('Error deleting movie: $e');
      throw e;
    }
  }

  Future<String?> uploadMovieImage(
    String movieId,
    Uint8List imageData,
    String type,
  ) async {
    try {
      final path = type == 'poster' ? 'movie_posters' : 'movie_heroes';
      Reference reference = _storage.ref().child('$path/$movieId.jpg');

      UploadTask uploadTask = reference.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Movie image upload error: $e');
      return null;
    }
  }
}