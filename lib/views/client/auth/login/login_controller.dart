import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  String _getErrorMessage(String code) {
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
}
