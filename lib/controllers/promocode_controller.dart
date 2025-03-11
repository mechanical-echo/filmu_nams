import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/promocode.dart';

class PromocodeController {
  static const _promocodesPath = "promocodes";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PromocodeModel> getPromocodeByName(String name) async {
    final QuerySnapshot querySnapshot = await _firestore
        .collection(_promocodesPath)
        .where('name', isEqualTo: name)
        .get();

    return PromocodeModel.fromMap(
      querySnapshot.docs.first.data() as Map<String, dynamic>,
      querySnapshot.docs.first.id,
    );
  }
}
