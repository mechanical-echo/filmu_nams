import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/carousel_item_model.dart';
import 'package:filmu_nams/models/movie_model.dart';
import 'package:filmu_nams/models/schedule_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/offer_model.dart';

class MovieController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static String carouselCollection = 'homescreen-carousel';

  Future<List<CarouselItemModel>> getHomescreenCarousel() async {
    final response = await _firestore.collection(carouselCollection).get();

    final futures = response.docs
        .map((doc) => CarouselItemModel.fromMapAsync(doc.data(), doc.id))
        .toList();
    return await Future.wait(futures);
  }

  Future<CarouselItemModel> getCarouselItemById(String id) async {
    final response =
        await _firestore.collection(carouselCollection).doc(id).get();

    return await CarouselItemModel.fromMapAsync(response.data()!, response.id);
  }

  Future<void> updateHomescreenCarousel(
    String id,
    String title,
    String description,
    Uint8List? image,
    String? url,
    MovieModel? movie,
    OfferModel? offer,
  ) async {
    String? uploadResult;

    if (image != null) {
      uploadResult = await uploadCoverImage(id, image);
    }

    final movieRef = _firestore.collection('movies').doc(movie?.id);
    final offerRef = _firestore.collection('offers').doc(offer?.id);

    await _firestore.collection(carouselCollection).doc(id).update({
      'title': title,
      'description': description,
      'image-url': url ?? uploadResult,
      'movie': movieRef,
      'offer': offerRef,
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
      rethrow;
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

  Future<void> addHomescreenCarousel(
    String title,
    String description,
    Uint8List? image,
    String? url,
    MovieModel? movie,
    OfferModel? offer,
  ) async {
    String? uploadResult;

    if (image != null) {
      uploadResult = await uploadCoverImage(title, image);
    }

    final movieRef = _firestore.collection('movies').doc(movie?.id);
    final offerRef = _firestore.collection('offers').doc(offer?.id);

    await _firestore.collection(carouselCollection).add({
      'title': title,
      'description': description,
      'image-url': url ?? uploadResult,
      'movie': movieRef,
      'offer': offerRef,
    });
  }

  Future<void> deleteCarouselItem(String id) async {
    try {
      await _firestore.collection(carouselCollection).doc(id).delete();
      await _storage.ref().child('carousel_covers/$id.jpg').delete();
    } catch (e) {
      debugPrint('Error deleting carousel item: $e');
    }
  }

  Future<void> updateMovie({
    required MovieModel movie,
    required String? title,
    required String? description,
    required String? genre,
    required String? director,
    required Timestamp? premiere,
    required int? duration,
    required String? rating,
    required List<dynamic> actors,
    required Uint8List? posterImage,
    required Uint8List? heroImage,
  }) async {
    String? posterUrl;
    String? heroUrl;

    if (posterImage != null) {
      posterUrl = await uploadMovieImage(movie.id, posterImage, 'poster');
    }

    if (heroImage != null) {
      heroUrl = await uploadMovieImage(movie.id, heroImage, 'hero');
    }

    return _firestore.collection('movies').doc(movie.id).update({
      'title': title,
      'description': description,
      'director': director,
      'genre': genre,
      'rating': rating,
      'duration': duration,
      'premiere': premiere,
      'actors': actors,
      'poster-url': posterUrl ?? movie.posterUrl,
      'hero-url': heroUrl ?? movie.heroUrl,
    });
  }

  Future<MovieModel?> addMovie({
    required String? title,
    required String? description,
    required String? genre,
    required String? director,
    required Timestamp? premiere,
    required int? duration,
    required String? rating,
    required List<dynamic> actors,
    required Uint8List? posterImage,
    required Uint8List? heroImage,
    String? poster,
    String? hero,
  }) async {
    String? posterUrl = poster;
    String? heroUrl = hero;

    if (posterImage != null) {
      posterUrl = await uploadMovieImage(title!, posterImage, 'poster');
    }

    if (heroImage != null) {
      heroUrl = await uploadMovieImage(title!, heroImage, 'hero');
    }

    _firestore
        .collection('movies')
        .add({
          'title': title,
          'description': description,
          'director': director,
          'genre': genre,
          'rating': rating,
          'duration': duration,
          'premiere': premiere,
          'actors': actors,
          'poster-url': posterUrl,
          'hero-url': heroUrl,
        })
        .then((response) => {
              debugPrint('Movie added with ID: ${response.id}'),
              response.get().then((doc) {
                return MovieModel.fromMap(doc.data()!, doc.id);
              }),
            })
        .catchError((error) {
          debugPrint('Error adding movie: $error');
          throw error;
        });
    return null;
  }
}
