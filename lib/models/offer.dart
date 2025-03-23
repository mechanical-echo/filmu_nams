import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/promocode.dart';
import 'package:flutter/material.dart';

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? linkedPromocodePath;
  final PromocodeModel? promocode;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.linkedPromocodePath,
    this.promocode,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map, String id) {
    return OfferModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['coverUrl'] ?? '',
      linkedPromocodePath: null,
      promocode: null,
    );
  }

  static Future<OfferModel> fromMapAsync(
      Map<String, dynamic> map, String id) async {
    PromocodeModel? promocode;
    String? linkedPromocodePath;

    if (map['linkedPromocode'] != null) {
      try {
        final promocodeRef = map['linkedPromocode'] as DocumentReference;
        linkedPromocodePath = promocodeRef.path;

        final promocodeSnapshot = await promocodeRef.get();
        if (promocodeSnapshot.exists) {
          promocode = PromocodeModel.fromMap(
            promocodeSnapshot.data() as Map<String, dynamic>,
            promocodeSnapshot.id,
          );
        }
      } catch (e) {
        debugPrint('Error fetching linked promocode: $e');
      }
    }

    return OfferModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['coverUrl'] ?? '',
      linkedPromocodePath: linkedPromocodePath,
      promocode: promocode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverUrl': imageUrl,
      'linkedPromocodePath': linkedPromocodePath,
    };
  }
}
