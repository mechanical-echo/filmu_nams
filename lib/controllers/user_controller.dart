import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:filmu_nams/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
      imageUrl = await uploadProfileImage(uid, payload.profileImage, null);
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

  Future<String?> uploadProfileImage(
    String userId,
    File? imageFile,
    Uint8List? imageFileWeb,
  ) async {
    try {
      Reference reference = _storage.ref().child('profile_images/$userId.jpg');

      UploadTask? uploadTask;
      if (imageFileWeb != null) {
        uploadTask = reference.putData(imageFileWeb);
      } else if (imageFile != null) {
        uploadTask = reference.putFile(imageFile);
      }

      if (uploadTask == null) {
        throw Exception('No valid image file provided for upload.');
      }

      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<RegistrationResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();
      if (user == null) {
        throw Exception(["Google login failure"]);
      }
      final GoogleSignInAuthentication auth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      UserDocumentPayload payload = UserDocumentPayload(
        name: user.displayName ?? '',
        email: user.email,
        profileImage: user.photoUrl,
      );

      await _auth.signInWithCredential(credential);
      await createUserDocument(_auth.currentUser!, payload);
      return RegistrationResponse(user: _auth.currentUser);
    } catch (exception) {
      debugPrint("Error google login: ${exception.toString()}");
      return RegistrationResponse(errorMessage: "Google login failure");
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();

      List<UserModel> users = querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return users;
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  Future<UserModel> getUserById(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      throw e;
    }
  }

  Future<void> updateUser(
    String uid,
    String name,
    String email,
    String role,
    File? profileImage,
    Uint8List? profileImageWeb,
  ) async {
    try {
      Map<String, dynamic> updateData = {
        'name': name,
        'email': email,
        'role': role,
      };

      if (profileImage != null || profileImageWeb != null) {
        String? imageUrl = await uploadProfileImage(uid, profileImage, profileImageWeb);
        if (profileImage != null) {
          await _auth.currentUser?.updatePhotoURL(imageUrl);
        }
        if (imageUrl != null) {
          updateData['profileImageUrl'] = imageUrl;
        }
      }

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  Future<bool> verifyAdminStatus() async {
    await FirebaseAuth.instance.currentUser?.reload();
    IdTokenResult tokenResult =
        await FirebaseAuth.instance.currentUser!.getIdTokenResult();
    bool isAdmin = tokenResult.claims?['admin'] == true;
    debugPrint('User admin status: $isAdmin');
    return isAdmin;
  }

  Future<Map<String, dynamic>> deleteUserFromAuth(String uid) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      functions.useFunctionsEmulator('localhost', 5001);

      await verifyAdminStatus();

      final result = await functions.httpsCallable('deleteUserAccount').call({
        'uid': uid,
      });

      debugPrint('Delete user result: ${result.data}');

      if (result.data['success']) {
        return {
          'success': true,
          'message': result.data['message'] ?? 'User deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message': result.data['message'] ?? 'Failed to delete user'
        };
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'Firebase function error: ${e.code} - ${e.message} - ${e.details}');
      return {
        'success': false,
        'message': e.message ?? 'Unknown error',
        'code': e.code,
        'details': e.details
      };
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String uid) async {
    try {
      Map<String, dynamic> result = await deleteUserFromAuth(uid);
      await deleteProfileImageFromStorage(uid);
      if (result['success']) {
        try {
          await _firestore.collection('users').doc(uid).delete();
          return result;
        } catch (e) {
          debugPrint('Error deleting user from Firestore: $e');
          return {
            'success': true,
            'message':
                '${result['message']} (Note: User document may still exist in database)',
            'firestore_error': e.toString()
          };
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error in deleteUser: $e');
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  deleteProfileImageFromStorage(String uid) async {
    try {
      Reference reference = _storage.ref().child('profile_images/$uid.jpg');
      return await reference.delete();
    } catch (e) {
      debugPrint('Image delete error: $e');
      return null;
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-.';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  Future<void> signInWithFacebook() async {
    if (Platform.isIOS) {
      return signInWithFacebookIOS();
    } else {
      return signInWithFacebookAndroid();
    }
  }

  Future<void> signInWithFacebookIOS() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final result = await FacebookAuth.instance.login(
      loginBehavior: LoginBehavior.nativeWithFallback,
      nonce: nonce,
    );

    if (result.status == LoginStatus.success) {
      debugPrint('${await FacebookAuth.instance.getUserData()}');
      final token = result.accessToken as LimitedToken;
      OAuthCredential credential = OAuthCredential(
        providerId: 'facebook.com',
        signInMethod: 'oauth',
        idToken: token.tokenString,
        rawNonce: rawNonce,
      );
      final response = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = response.user;

      UserDocumentPayload payload = UserDocumentPayload(
        name: user!.displayName!,
        email: user.email!,
        profileImage: user.photoURL,
      );

      await createUserDocument(user, payload);
    }
  }

  Future<void> signInWithFacebookAndroid() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final LoginResult result = await FacebookAuth.instance.login(
        loginBehavior: LoginBehavior.nativeWithFallback,
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        debugPrint('Facebook user data: $userData');

        final accessToken = result.accessToken?.tokenString;

        if (accessToken == null) {
          throw FirebaseAuthException(
            code: 'facebook-auth-token-null',
            message: 'Facebook access token is null',
          );
        }

        final facebookAuthCredential = FacebookAuthProvider.credential(accessToken);

        final userCredential = await FirebaseAuth.instance.signInWithCredential(
            facebookAuthCredential
        );

        final user = userCredential.user;
        if (user != null && user.email != null && user.displayName != null) {
          UserDocumentPayload payload = UserDocumentPayload(
            name: user.displayName!,
            email: user.email!,
            profileImage: user.photoURL,
          );

          await createUserDocument(user, payload);
        } else {
          debugPrint('User data incomplete: ${user?.displayName}, ${user?.email}');
        }
      } else {
        debugPrint('Facebook login failed: ${result.status.toString()}');
        if (result.message != null) {
          debugPrint('Facebook login error message: ${result.message}');
        }
      }
    } catch (e) {
      debugPrint('Error during Facebook sign in: $e');
    }
  }

  Future<void> updateOwnProfile(
      String name,
      String email,
      File? profileImage,
  ) async {
    String uid = _auth.currentUser!.uid;
    await updateUser(uid, name, email, UserRolesEnum.user, profileImage, null);
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
