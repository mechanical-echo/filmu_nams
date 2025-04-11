import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'movie.dart';
import 'offer.dart';

class CarouselItemModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final MovieModel? movie;
  final OfferModel? offer;

  CarouselItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    this.movie,
    this.offer,
  });

  factory CarouselItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CarouselItemModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['image-url'] ?? '',
      description: map['description'] ?? '',
    );
  }

  static Future<CarouselItemModel> fromMapAsync(
      Map<String, dynamic> map,
      String id,
  ) async {
    MovieModel? movie;
    OfferModel? offer;

    if (map['offer'] != null) {
      try {
        final offerRef = map['offer'] as DocumentReference;

        final offerSnapshot = await offerRef.get();
        if (offerSnapshot.exists) {
          offer = await OfferModel.fromMapAsync(
            offerSnapshot.data() as Map<String, dynamic>,
            offerSnapshot.id,
          );
        }
      } catch (e) {
        debugPrint('Error fetching offer from carousel item: $e');
      }
    }

    if (map['movie'] != null) {
      try {
        final movieRef = map['movie'] as DocumentReference;

        final movieSnapshot = await movieRef.get();
        if (movieSnapshot.exists) {
          movie = MovieModel.fromMap(
            movieSnapshot.data() as Map<String, dynamic>,
            movieSnapshot.id,
          );
        }
      } catch (e) {
        debugPrint('Error fetching movie from carousel item: $e');
      }
    }

    return CarouselItemModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['image-url'] ?? '',
      description: map['description'] ?? '',
      movie: movie,
      offer: offer,
    );
  }

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'title': title,
        'image-url': imageUrl,
        'description': description,
        'movie': movie,
        'offer': offer,
      };
    }
  }
