import 'package:filmu_nams/views/resources/text_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationFirstStep extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final Function(int) onViewChange;
  final VoidCallback nextRegistrationStep;
  const RegistrationFirstStep({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.onViewChange,
    required this.nextRegistrationStep,
  });

  @override
  State<RegistrationFirstStep> createState() => _RegistrationFirstStepState();
}

class _RegistrationFirstStepState extends State<RegistrationFirstStep> {
  String? emailError;
  String? passwordError;
  String? passwordConfirmationError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 25),
          child: Text(
            'Prieks iepazīties!',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none),
          ),
        ),
        TextInput(
          obscureText: false,
          labelText: "E-pasts",
          hintText: "epasts@epasts.lv",
          icon: Icon(Icons.email),
          margin: [25, 35, 25, 35],
          controller: widget.emailController,
          error: emailError,
        ),
        TextInput(
          obscureText: true,
          labelText: "Parole",
          hintText: "dro\$aParole1",
          margin: [0, 35, 25, 35],
          controller: widget.passwordController,
          error: passwordError,
        ),
        TextInput(
          obscureText: true,
          labelText: "Parole atkārtoti",
          hintText: "dro\$aParole1",
          margin: [0, 35, 0, 35],
          controller: widget.passwordConfirmationController,
          error: passwordConfirmationError,
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Ir konts?",
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 167, 167, 167),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                TextButton(
                  onPressed: () => {widget.onViewChange(0)},
                  child: Text("Ielogoties"),
                )
              ],
            ),
            FilledButton(
              onPressed: () {
                if (areFieldsValid()) {
                  widget.nextRegistrationStep();
                }
              },
              child: Text(
                "Reģistrēties",
              ),
            ),
          ],
        )
      ]),
    );
  }

  bool areFieldsValid() {
    emailError = passwordError = passwordConfirmationError = null;
    return checkEmptyFields() && validatePassword() && validateEmail();
  }

  bool checkEmptyFields() {
    String? email = widget.emailController.text;
    String? password = widget.passwordController.text;
    String? passwordConfirmation = widget.passwordConfirmationController.text;

    bool isValid = true;

    if (email.isEmpty) {
      setState(() {
        emailError = "Lūdzu, ievadiet e-pastu";
      });

      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = "Lūdzu, ievadiet paroli";
      });

      isValid = false;
    }

    if (passwordConfirmation.isEmpty) {
      setState(() {
        passwordConfirmationError = "Lūdzu, ievadiet paroli atkārtoti";
      });

      isValid = false;
    }

    return isValid;
  }

  bool validatePassword() {
    String? password = widget.passwordController.text;
    String? passwordConfirmation = widget.passwordConfirmationController.text;

    bool isValid = true;

    if (password != passwordConfirmation) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text("Kļūda"),
          content: Text("Paroles nesakrīt"),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );

      isValid = false;
    }

    if (password.length < 8) {
      setState(() {
        passwordError = "Parolei jābūt vismaz 8 simboliem garai";
      });

      isValid = false;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      setState(() {
        passwordError = "Parolē jābūt vismaz 1 lielām burtam";
      });

      isValid = false;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      setState(() {
        passwordError = "Parolē jābūt vismaz 1 mazām burtam";
      });

      isValid = false;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      setState(() {
        passwordError = "Parolē jābūt vismaz 1 skaitlim";
      });

      isValid = false;
    }

    return isValid;
  }

  bool validateEmail() {
    String? email = widget.emailController.text;
    bool isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);

    if (!isValid) {
      setState(() {
        emailError = "Lūdzu, ievadiet derīgu e-pastu";
      });
    }

    return isValid;
  }
}
