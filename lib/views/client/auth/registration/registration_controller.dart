import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register(String name, String email, String password) async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });

      // Send email verification
      await userCredential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Parole ir pārāk vāja';
      case 'email-already-in-use':
        return 'E-pasts jau ir reģistrēts';
      case 'invalid-email':
        return 'Nederīgs e-pasta formāts';
      case 'operation-not-allowed':
        return 'Reģistrācija pa e-pastu nav iespējota';
      default:
        return 'Radās kļūda. Lūdzu, mēģiniet vēlāk';
    }
  }
}
