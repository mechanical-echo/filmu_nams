class RegistrationValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lūdzu, ievadiet vārdu';
    }

    if (value.length < 2) {
      return 'Vārdam jābūt vismaz 2 rakstzīmes garam';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lūdzu, ievadiet e-pastu';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Lūdzu, ievadiet derīgu e-pasta adresi';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lūdzu, ievadiet paroli';
    }

    if (value.length < 6) {
      return 'Parolei jābūt vismaz 6 rakstzīmes garai';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Parolei jāsatur vismaz vienu lielo burtu';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Parolei jāsatur vismaz vienu mazo burtu';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Parolei jāsatur vismaz vienu ciparu';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Lūdzu, apstipriniet paroli';
    }

    if (value != password) {
      return 'Paroles nesakrīt';
    }

    return null;
  }
}
