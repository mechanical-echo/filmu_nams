import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/offer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class OfferController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  Future<String?> uploadOfferImage(String offerId, Uint8List imageData) async {
    try {
      Reference reference = _storage.ref().child('offer_images/$offerId.jpg');

      UploadTask uploadTask = reference.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Offer image upload error: $e');
      return null;
    }
  }

  Future<void> deleteOfferImage(String offerId) async {
    try {
      Reference reference = _storage.ref().child('offer_images/$offerId.jpg');
      await reference.delete();
    } catch (e) {
      debugPrint('Error deleting offer image: $e');
    }
  }

  Future<String?> addOffer({
    required String title,
    required String description,
    Uint8List? imageData,
    DocumentReference? promocodeRef,
  }) async {
    try {
      DocumentReference docRef = _firestore.collection(_offersPath).doc();

      String? imageUrl;
      if (imageData != null) {
        imageUrl = await uploadOfferImage(docRef.id, imageData);
      }

      Map<String, dynamic> offerData = {
        'title': title,
        'description': description,
        'coverUrl': imageUrl,
        'linkedPromocode': promocodeRef,
      };

      await docRef.set(offerData);

      return docRef.id;
    } catch (e) {
      debugPrint('Error adding offer: $e');
      return null;
    }
  }

  Future<bool> updateOffer({
    required String id,
    required String title,
    required String description,
    Uint8List? imageData,
    String? currentImageUrl,
    DocumentReference? promocodeRef,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'title': title,
        'description': description,
        'linkedPromocode': promocodeRef,
      };

      if (imageData != null) {
        String? newImageUrl = await uploadOfferImage(id, imageData);
        if (newImageUrl != null) {
          updateData['coverUrl'] = newImageUrl;
        }
      } else if (currentImageUrl != null) {
        updateData['coverUrl'] = currentImageUrl;
      }

      await _firestore.collection(_offersPath).doc(id).update(updateData);

      return true;
    } catch (e) {
      debugPrint('Error updating offer: $e');
      return false;
    }
  }

  Future<bool> deleteOffer(String id) async {
    try {
      await _firestore.collection(_offersPath).doc(id).delete();

      try {
        await deleteOfferImage(id);
      } catch (e) {
        debugPrint('Error deleting offer image: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      return false;
    }
  }
}
