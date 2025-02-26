import 'package:cloud_firestore/cloud_firestore.dart';

class MovieController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getHomescreenCarousel() async {
    final response = await _firestore.collection('homescreen-carousel').get();

    return response.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateHomescreenCarousel(
    String id,
    String title,
    String description,
    String imageUrl,
  ) async {
    await _firestore.collection('homescreen-carousel').doc(id).update({
      'title': title,
      'description': description,
      'image-url': imageUrl,
    });
  }
}
