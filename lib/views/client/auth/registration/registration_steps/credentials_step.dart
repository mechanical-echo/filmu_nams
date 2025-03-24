import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:filmu_nams/validators/validator.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../providers/color_context.dart';

class CredentialsStep extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final Function(int) onViewChange;
  final VoidCallback nextRegistrationStep;

  const CredentialsStep({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.onViewChange,
    required this.nextRegistrationStep,
  });

  @override
  State<CredentialsStep> createState() => _CredentialsStepState();
}

class _CredentialsStepState extends State<CredentialsStep> {
  String? emailError;
  String? passwordError;
  String? passwordConfirmationError;
  final Validator validator = Validator();

  String get email => widget.emailController.text;
  String get password => widget.passwordController.text;
  String get passwordConfirmation => widget.passwordConfirmationController.text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const _StepTitle(),
          _CredentialsForm(
            emailController: widget.emailController,
            passwordController: widget.passwordController,
            passwordConfirmationController:
                widget.passwordConfirmationController,
            emailError: emailError,
            passwordError: passwordError,
            passwordConfirmationError: passwordConfirmationError,
          ),
          _ActionButtons(
            onViewChange: widget.onViewChange,
            onNext: _validateAndProceed,
          ),
        ],
      ),
    );
  }

  void _validateAndProceed() {
    if (_validateFields()) {
      widget.nextRegistrationStep();
    }
  }

  bool _validateFields() {
    setState(() {
      emailError = passwordError = passwordConfirmationError = null;
    });

    final validations = [
      _validatePassword(),
      _validateEmail(),
      _validateRequiredFields(),
    ];

    return !validations.contains(false);
  }

  bool _validatePassword() {
    final validation =
        validator.validatePassword(password, passwordConfirmation);
    if (validation.isNotValid) {
      if (validation.problematicFields.contains("passwordConfirmation")) {
        StylizedDialog.alert(context, "Kļūda", "Paroles nesakrīt");
        setState(() => passwordConfirmationError = validation.error);
      } else {
        setState(() => passwordError = validation.error);
      }
      return false;
    }
    return true;
  }

  bool _validateEmail() {
    final validation = validator.validateEmail(email, true);
    if (validation.isNotValid) {
      setState(() => emailError = validation.error);
      return false;
    }
    return true;
  }

  bool _validateRequiredFields() {
    final validation = validator.checkEmptyFields({
      "password": password,
      "passwordConfirmation": passwordConfirmation,
      "email": email,
    });

    if (validation.isNotValid) {
      setState(() {
        for (var field in validation.problematicFields) {
          switch (field) {
            case "password":
              passwordError = validation.error;
              break;
            case "passwordConfirmation":
              passwordConfirmationError = validation.error;
              break;
            case "email":
              emailError = validation.error;
              break;
          }
        }
      });
      return false;
    }
    return true;
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle();

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 25),
      padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 5),
      decoration: colors.classicDecorationWhiteSharper,
      child: Text(
        'Prieks\niepazīties!',
        style: colors.header2ThemeColor,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CredentialsForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final String? emailError;
  final String? passwordError;
  final String? passwordConfirmationError;

  const _CredentialsForm({
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    this.emailError,
    this.passwordError,
    this.passwordConfirmationError,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 35, top: 15),
          child: Text(
            "E-pasts",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextInput(
          obscureText: false,
          hintText: "epasts@epasts.lv",
          icon: Icon(
            Icons.email,
            color: colors.color001,
          ),
          margin: [10, 35, 20, 35],
          controller: emailController,
          error: emailError,
          obligatory: true,
        ),
        Container(
          margin: const EdgeInsets.only(left: 35),
          child: Text(
            "Parole",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextInput(
          obscureText: true,
          hintText: "dro\$aParole1",
          margin: [10, 35, 20, 35],
          controller: passwordController,
          error: passwordError,
          obligatory: true,
        ),
        Container(
          margin: const EdgeInsets.only(left: 35),
          child: Text(
            "Parole atkārtoti",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextInput(
          obscureText: true,
          hintText: "dro\$aParole1",
          margin: const [10, 35, 0, 35],
          controller: passwordConfirmationController,
          error: passwordConfirmationError,
          obligatory: true,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Function(int) onViewChange;
  final VoidCallback onNext;

  const _ActionButtons({
    required this.onViewChange,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ir konts?",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed: () => onViewChange(0),
              child: const Text("Ielogoties"),
            )
          ],
        ),
        IntrinsicWidth(
          child: StylizedButton(
            action: onNext,
            title: "Reģistrēties",
            icon: Icons.person_add_rounded,
          ),
        ),
      ],
    );
  }
}
