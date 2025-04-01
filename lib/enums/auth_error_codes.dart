enum FirebaseAuthErrorCode {
  userNotFound,
  wrongPassword,
  invalidEmail,
  emailAlreadyInUse,
  operationNotAllowed,
  weakPassword,
  userDisabled,
  tooManyRequests,
  networkRequestFailed,
  requiresRecentLogin,
  unknownError,
}

extension FirebaseAuthErrorCodeExtension on FirebaseAuthErrorCode {
  String get message {
    switch (this) {
      case FirebaseAuthErrorCode.userNotFound:
      // return 'Lietotājs nav atrasts.';
      case FirebaseAuthErrorCode.wrongPassword:
        // return 'Nepareiza parole.';
        return 'Nepareiza parole vai e-pasts.';
      case FirebaseAuthErrorCode.invalidEmail:
        return 'Nederīgs e-pasts.';
      case FirebaseAuthErrorCode.emailAlreadyInUse:
        return 'E-pasts jau tiek izmantots.';
      case FirebaseAuthErrorCode.operationNotAllowed:
        return 'Operācija nav atļauta.';
      case FirebaseAuthErrorCode.weakPassword:
        return 'Parole ir pārāk vāja.';
      case FirebaseAuthErrorCode.userDisabled:
        return 'Lietotājs nav aktīvs.';
      case FirebaseAuthErrorCode.tooManyRequests:
        return 'Pārāk daudz pieprasījumu. Lūdzu, mēģiniet vēlāk.';
      case FirebaseAuthErrorCode.networkRequestFailed:
        return 'Problēmas ar interneta savienojumu.';
      case FirebaseAuthErrorCode.requiresRecentLogin:
        return 'Šai darbībai nepieciešama nesena autentifikācija. Lūdzu, pierakstieties no jauna.';
      case FirebaseAuthErrorCode.unknownError:
        return 'Nezināma kļūda.';
    }
  }
}

getFirebaseAuthErrorCode(String? code) {
  switch (code) {
    case "user-not-found":
      return FirebaseAuthErrorCode.userNotFound.message;
    case "wrong-password":
      return FirebaseAuthErrorCode.wrongPassword.message;
    case "invalid-email":
      return FirebaseAuthErrorCode.invalidEmail.message;
    case "email-already-in-use":
      return FirebaseAuthErrorCode.emailAlreadyInUse.message;
    case "operation-not-allowed":
      return FirebaseAuthErrorCode.operationNotAllowed.message;
    case "weak-password":
      return FirebaseAuthErrorCode.weakPassword.message;
    case "user-disabled":
      return FirebaseAuthErrorCode.userDisabled.message;
    case "too-many-requests":
      return FirebaseAuthErrorCode.tooManyRequests.message;
    case "network-request-failed":
      return FirebaseAuthErrorCode.networkRequestFailed.message;
    case "requires-recent-login":
      return FirebaseAuthErrorCode.requiresRecentLogin.message;
    default:
      return FirebaseAuthErrorCode.unknownError.message;
  }
}

class AuthErrorCodes {
  static String getMessage(String code) {
    return getFirebaseAuthErrorCode(code);
  }
}
