import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/promocode.dart';
import 'package:flutter/material.dart';

class PromocodeController {
  static const _promocodesPath = "promocodes";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PromocodeModel?> getPromocodeById(String id) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _firestore.collection(_promocodesPath).doc(id).get();

      if (!documentSnapshot.exists) {
        return null;
      }

      return PromocodeModel.fromMap(
        documentSnapshot.data() as Map<String, dynamic>,
        documentSnapshot.id,
      );
    } catch (e) {
      debugPrint('Error fetching promocode by ID: $e');
      return null;
    }
  }

  Future<PromocodeModel?> getPromocodeByName(String name) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_promocodesPath)
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return PromocodeModel.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
        querySnapshot.docs.first.id,
      );
    } catch (e) {
      debugPrint('Error fetching promocode by name: $e');
      return null;
    }
  }

  Future<List<PromocodeModel>> getAllPromocodes() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection(_promocodesPath).get();

      return querySnapshot.docs
          .map((doc) => PromocodeModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all promocodes: $e');
      return [];
    }
  }

  Future<String?> addPromocode({
    required String name,
    double? amount,
    int? percents,
  }) async {
    try {
      PromocodeModel? existing = await getPromocodeByName(name);
      if (existing != null) {
        return null;
      }

      Map<String, dynamic> promocodeData = {
        'name': name,
      };

      if (amount != null) {
        promocodeData['amount'] = amount;
      } else if (percents != null) {
        promocodeData['percents'] = percents;
      } else {
        return null;
      }

      DocumentReference docRef =
          await _firestore.collection(_promocodesPath).add(promocodeData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding promocode: $e');
      return null;
    }
  }

  Future<bool> updatePromocode({
    required String id,
    required String name,
    double? amount,
    int? percents,
  }) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_promocodesPath)
          .where('name', isEqualTo: name)
          .get();

      for (var doc in querySnapshot.docs) {
        if (doc.id != id) {
          return false;
        }
      }

      Map<String, dynamic> updateData = {
        'name': name,
      };

      if (amount != null) {
        updateData['amount'] = amount;
        updateData['percents'] = null;
      } else if (percents != null) {
        updateData['percents'] = percents;
        updateData['amount'] = null;
      } else {
        return false;
      }

      await _firestore.collection(_promocodesPath).doc(id).update(updateData);
      return true;
    } catch (e) {
      debugPrint('Error updating promocode: $e');
      return false;
    }
  }

  Future<bool> deletePromocode(String id) async {
    try {
      final QuerySnapshot linkedOffers = await _firestore
          .collection('offers')
          .where('linkedPromocode',
              isEqualTo: _firestore.collection(_promocodesPath).doc(id))
          .get();

      if (linkedOffers.docs.isNotEmpty) {
        return false;
      }

      await _firestore.collection(_promocodesPath).doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting promocode: $e');
      return false;
    }
  }

  Future<bool> validatePromocode(String name) async {
    try {
      PromocodeModel? promocode = await getPromocodeByName(name);
      return promocode != null;
    } catch (e) {
      debugPrint('Error validating promocode: $e');
      return false;
    }
  }
}
