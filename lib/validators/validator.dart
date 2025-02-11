class ValidatorResult {
  String? error;
  bool isValid = false;
  bool isNotValid = true;
  List<String> problematicFields = [];

  ValidatorResult(String this.error, this.isValid, this.problematicFields) {
    isNotValid = !isValid;
  }
}

class Validator {
  ValidatorResult validatePassword(
      String password, String? passwordConfirmation) {
    bool isValid = true;
    String passwordError = "";
    List<String> problematicFields = [];

    if (password != passwordConfirmation && passwordConfirmation != null) {
      passwordError = "Paroles nesakrīt";
      isValid = false;
      problematicFields.addAll(["passwordConfirmation"]);
    }

    if (password.length < 8) {
      passwordError = "Parolei jābūt vismaz 8 simboliem garai";

      isValid = false;
      problematicFields.add("password");
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      passwordError = "Parolē jābūt vismaz 1 lielām burtam";

      isValid = false;
      problematicFields.add("password");
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      passwordError = "Parolē jābūt vismaz 1 mazām burtam";

      isValid = false;
      problematicFields.add("password");
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      passwordError = "Parolē jābūt vismaz 1 skaitlim";

      isValid = false;
      problematicFields.add("password");
    }

    return ValidatorResult(
      passwordError,
      isValid,
      problematicFields,
    );
  }

  ValidatorResult validateEmail(String email) {
    bool isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);

    String emailError = "";
    List<String> problematicFields = [];

    if (!isValid) {
      emailError = "Lūdzu, ievadiet derīgu e-pastu";
      problematicFields.add("email");
    }

    return ValidatorResult(emailError, isValid, problematicFields);
  }

  ValidatorResult checkEmptyFields(Map<String, dynamic> fields) {
    String error = "";
    bool isValid = true;
    List<String> problematicFields = [];

    for (String field in fields.keys) {
      if (fields[field].isEmpty) {
        error = "Lūdzu, aizpildiet lauku";
        isValid = false;
        problematicFields.add(field);
      }
    }

    return ValidatorResult(
      error,
      isValid,
      problematicFields,
    );
  }

  ValidatorResult validateName(String? name) {
    String error = "";
    bool isValid = true;
    List<String> problematicFields = [];

    if (name == null || name.isEmpty) {
      error = "Ievadiet savu vārdu";
      isValid = false;
      problematicFields.add("name");
    }

    if (name!.length > 20) {
      error = "Vārds nedrīkst būt garāks par 20 simboliem";
      isValid = false;
      problematicFields.add("name");
    }

    return ValidatorResult(
      error,
      isValid,
      problematicFields,
    );
  }
}
