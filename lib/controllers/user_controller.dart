import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:filmu_nams/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static const String usersPath = 'users';

  User? getCurrentUser() {
    return _auth.currentUser;
  }

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

      UserDocumentPayload payload = UserDocumentPayload(
        name: name,
        email: email,
        profileImage: profileImage,
      );

      await createUserDocument(user, payload);

      _auth.signOut();

      return RegistrationResponse(user: user);
    } on FirebaseAuthException catch (e) {
      return RegistrationResponse(errorMessage: e.code);
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final result = await _functions.httpsCallable('getAllUsers').call();

      final List<dynamic> usersData = result.data['users'];
      final List<UserModel> users = usersData.map((userData) {
        final createdAtTimestamp = Timestamp.fromDate(DateTime.parse(
            userData['createdAt'] ?? DateTime.now().toIso8601String()));

        return UserModel(
          id: userData['id'],
          createdAt: createdAtTimestamp,
          email: userData['email'] ?? '',
          name: userData['name'] ?? '',
          profileImageUrl: userData['profileImageUrl'] ?? '',
          role: userData['role'] ?? '',
        );
      }).toList();

      return users;
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final result = await _functions.httpsCallable('getUserById').call({
        'uid': uid,
        'currentUid': getCurrentUser()!.uid,
      });

      if (result.data == null) {
        return null;
      }

      final userData = result.data;

      return UserModel(
        id: userData['id'] ?? '',
        createdAt: Timestamp.fromDate(DateTime.parse(
            userData['createdAt'] ?? DateTime.now().toIso8601String())),
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
        profileImageUrl: userData['profileImageUrl'] ?? '',
        role: userData['role'] ?? '',
      );
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(String userId, Uint8List imageData) async {
    try {
      Reference reference = _storage.ref().child('profile_images/$userId.jpg');

      UploadTask uploadTask = reference.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Profile image upload error: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      Reference reference = _storage.ref().child('profile_images/$userId.jpg');
      await reference.delete();
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }

  Future<String?> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    Uint8List? profileImage,
  }) async {
    try {
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await uploadProfileImage(name, profileImage);
      }

      final result = await _functions.httpsCallable('createUser').call({
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        'profileImageUrl': imageUrl,
        'currentUid': getCurrentUser()!.uid
      });

      return result.data['uid'];
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  Future<bool> updateUser({
    required String uid,
    required String name,
    required String email,
    required String role,
    Uint8List? profileImage,
    bool deleteImage = false,
  }) async {
    try {
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await uploadProfileImage(uid, profileImage);
      }

      final result = await _functions.httpsCallable('updateUser').call({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'profileImageUrl': imageUrl,
        'deleteImage': deleteImage,
        'currentUid': getCurrentUser()!.uid
      });

      return result.data['success'] ?? false;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  Future<void> updateOwnProfile({
    required String name,
    required String email,
    File? profileImage,
    Uint8List? profileImageWeb,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      String uid = currentUser.uid;
      String role = 'user';

      DocumentSnapshot userDoc =
          await _firestore.collection(usersPath).doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        role = userData['role'] ?? 'user';
      }

      Uint8List? imageData;
      if (profileImage != null) {
        imageData = await profileImage.readAsBytes();
      } else if (profileImageWeb != null) {
        imageData = profileImageWeb;
      }

      await updateUser(
        uid: uid,
        name: name,
        email: email,
        role: role,
        profileImage: imageData,
      );
    } catch (e) {
      debugPrint('Error updating own profile: $e');
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      final result = await _functions.httpsCallable('deleteUser').call({
        'uid': uid,
        'currentUid': getCurrentUser()!.uid,
      });

      return result.data['success'] ?? false;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  Future<bool> userHasRole(String uid, String role) async {
    try {
      UserModel? user = await getUserById(uid);
      return user?.role == role;
    } catch (e) {
      debugPrint('Error checking user role: $e');
      return false;
    }
  }

  Future<UserModel?> getCurrentUserModel() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection(usersPath).doc(user.uid).get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      return UserModel(
        id: user.uid,
        createdAt: userData['createdAt'] ?? Timestamp.now(),
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
        profileImageUrl: userData['profileImageUrl'] ?? '',
        role: userData['role'] ?? '',
      );
    } catch (e) {
      debugPrint('Error getting current user model: $e');
      return null;
    }
  }

  Future<void> createUserDocument(
    User user,
    UserDocumentPayload payload,
  ) async {
    String uid = user.uid;

    final existingDoc = await _firestore.collection('users').doc(uid).get();

    if (existingDoc.exists) {
      return;
    }

    String? imageUrl =
        payload.profileImage is String ? payload.profileImage : null;

    if (payload.profileImage != null && payload.profileImage is File) {
      imageUrl = await uploadProfileImage(uid, payload.profileImage);
    }

    await _firestore.collection('users').doc(uid).set({
      'name': payload.name,
      'email': payload.email,
      'profileImageUrl': imageUrl,
      'role': UserRolesEnum.user,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.updateDisplayName(payload.name);
    if (imageUrl != null) {
      await user.updatePhotoURL(imageUrl);
    }
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

class UserDocumentPayload {
  final String name;
  final String email;
  final dynamic profileImage;

  UserDocumentPayload({
    this.name = '',
    this.email = '',
    this.profileImage,
  });
}

class UserRolesEnum {
  static const String admin = 'admin';
  static const String user = 'user';
}
