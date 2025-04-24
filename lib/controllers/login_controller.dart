import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userController = UserController();

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  static String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Lietotājs ar šādu e-pastu nav atrasts';
      case 'wrong-password':
        return 'Nepareiza parole';
      case 'invalid-email':
        return 'Nederīgs e-pasta formāts';
      case 'user-disabled':
        return 'Lietotāja konts ir deaktivizēts';
      case 'too-many-requests':
        return 'Pārāk daudz mēģinājumu. Lūdzu, mēģiniet vēlāk';
      default:
        return 'Radās kļūda. Lūdzu, mēģiniet vēlāk';
    }
  }

  String getMessage(String code) {
    return _getErrorMessage(code);
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
      final response =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = response.user;

      UserDocumentPayload payload = UserDocumentPayload(
        name: user!.displayName!,
        email: user.email!,
        profileImage: user.photoURL,
      );

      await _userController.createUserDocument(user, payload);
    }
  }

  Future<void> signInWithFacebookAndroid() async {
    try {
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

        final facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken);

        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        final user = userCredential.user;
        if (user != null && user.email != null && user.displayName != null) {
          UserDocumentPayload payload = UserDocumentPayload(
            name: user.displayName!,
            email: user.email!,
            profileImage: user.photoURL,
          );

          await _userController.createUserDocument(user, payload);
        } else {
          debugPrint(
              'User data incomplete: ${user?.displayName}, ${user?.email}');
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

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-.';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
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
      await _userController.createUserDocument(_auth.currentUser!, payload);
      return RegistrationResponse(user: _auth.currentUser);
    } catch (exception) {
      debugPrint("Error google login: ${exception.toString()}");
      return RegistrationResponse(errorMessage: "Google login failure");
    }
  }
}
