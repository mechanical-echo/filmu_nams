class LoginValidator {
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

    return null;
  }
}
