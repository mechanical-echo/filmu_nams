import 'package:filmu_nams/views/resources/dialog/dialog.dart';
import 'package:filmu_nams/views/resources/input/text_input.dart';
import 'package:filmu_nams/views/resources/validators/validator.dart';
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

  Validator validator = Validator();

  get email => widget.emailController.text;
  get password => widget.passwordController.text;
  get passwordConfirmation => widget.passwordConfirmationController.text;

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
          obligatory: true,
        ),
        TextInput(
          obscureText: true,
          labelText: "Parole",
          hintText: "dro\$aParole1",
          margin: [0, 35, 25, 35],
          controller: widget.passwordController,
          error: passwordError,
          obligatory: true,
        ),
        TextInput(
          obscureText: true,
          labelText: "Parole atkārtoti",
          hintText: "dro\$aParole1",
          margin: [0, 35, 0, 35],
          controller: widget.passwordConfirmationController,
          error: passwordConfirmationError,
          obligatory: true,
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
    bool isValid = true;

    ValidatorResult passwordValidation = validator.validatePassword(
      password,
      passwordConfirmation,
    );
    ValidatorResult emailValidation = validator.validateEmail(email);
    ValidatorResult emptyFieldsValidation = validator.checkEmptyFields({
      "password": password,
      "passwordConfirmation": passwordConfirmation,
      "email": email,
    });

    if (passwordValidation.isNotValid) {
      if (passwordValidation.problematicFields.contains(
        "passwordConfirmation",
      )) {
        StylizedDialog.alert(
          context,
          "Kļūda",
          "Paroles nesakrīt",
        );

        setState(() {
          passwordConfirmationError = passwordValidation.error;
        });
      } else {
        setState(() {
          passwordError = passwordValidation.error;
        });
      }

      isValid = false;
    }

    if (emailValidation.isNotValid) {
      setState(() {
        emailError = emailValidation.error;
      });

      isValid = false;
    }

    if (emptyFieldsValidation.isNotValid) {
      for (var field in emptyFieldsValidation.problematicFields) {
        switch (field) {
          case "password":
            setState(() {
              passwordError = emptyFieldsValidation.error;
            });
            break;
          case "passwordConfirmation":
            setState(() {
              passwordConfirmationError = emptyFieldsValidation.error;
            });
            break;
          case "email":
            setState(() {
              emailError = emptyFieldsValidation.error;
            });
            break;
        }
      }

      isValid = false;
    }

    return isValid;
  }
}
