import 'package:cloud_firestore/cloud_firestore.dart';

class MovieController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getHomescreenCarousel() async {
    final response = await _firestore.collection('homescreen-carousel').get();

    return response.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMovies() async {
    final response = await _firestore.collection('movies').get();

    return response.docs.map((doc) => doc.data()).toList();
  }
}
