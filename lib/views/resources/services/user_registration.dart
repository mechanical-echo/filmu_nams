import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationResponse {
  final String? errorMessage;
  final User? user;

  RegistrationResponse({
    this.errorMessage,
    this.user,
  });
}

class UserRegistrationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<RegistrationResponse?> registerUser({
    required String email,
    required String password,
    required String name,
    File? profileImage,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user == null) return null;

      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await _uploadProfileImage(user.uid, profileImage);
      }

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'profileImageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await user.updateProfile(
        displayName: name,
        photoURL: imageUrl,
      );

      return RegistrationResponse(user: user);
    } on FirebaseAuthException catch (e) {
      return RegistrationResponse(errorMessage: e.code);
    }
  }

  Future<String?> _uploadProfileImage(String userId, File imageFile) async {
    try {
      Reference reference = _storage.ref().child('profile_images/$userId.jpg');

      UploadTask uploadTask = reference.putFile(imageFile);

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }
}
