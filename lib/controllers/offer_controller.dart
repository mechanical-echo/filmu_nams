import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/offer.dart';
import 'package:flutter/material.dart';

class OfferController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _offersPath = "offers";

  Future<List<OfferModel>> getAllOffers() async {
    try {
      final response = await _firestore.collection(_offersPath).get();
      final futures = response.docs
          .map((doc) => OfferModel.fromMapAsync(doc.data(), doc.id))
          .toList();

      return await Future.wait(futures);
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      return [];
    }
  }

  Future<OfferModel?> getOfferById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _firestore.collection(_offersPath).doc(id).get();

      if (!documentSnapshot.exists) {
        return null;
      }

      return await OfferModel.fromMapAsync(
        documentSnapshot.data() as Map<String, dynamic>,
        documentSnapshot.id,
      );
    } catch (e) {
      debugPrint('Error fetching offer: $e');
      return null;
    }
  }
}
