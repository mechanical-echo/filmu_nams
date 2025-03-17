import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocument(
    String uid,
  ) async {
    try {
      if (_auth.currentUser == null) return null;
      var userDocument =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDocument;
    } catch (e) {
      debugPrint('Error getting user document: $e');
      return null;
    }
  }

  /// Parbaudit vai lietotajam ir dota loma
  Future<bool> userHasRole(
    User user,
    String role,
  ) async {
    try {
      var userDocument = await getUserDocument(user.uid);
      if (userDocument == null) return false;
      return userDocument.data()?['role'] == role;
    } catch (e) {
      debugPrint('Error checking user role: $e');
      return false;
    }
  }

  /// Pieregistret jauno lietotaju
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
        'role': 'user',
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
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? user = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication auth = await user!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
}

class RegistrationResponse {
  final String? errorMessage;
  final User? user;

  RegistrationResponse({
    this.errorMessage,
    this.user,
  });
}
