import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/components/form_input.dart';
import 'package:filmu_nams/assets/components/auth_container.dart';
import 'package:filmu_nams/validators/validator.dart';
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
    return AuthContainer(
      title: 'Reģistrācija',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Izveidot kontu',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          FormInput(
            controller: widget.emailController,
            hintText: "epasts@epasts.lv",
            icon: Icons.email,
            error: emailError,
            obligatory: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          FormInput(
            controller: widget.passwordController,
            hintText: "dro\$aParole1",
            icon: Icons.lock,
            obscureText: true,
            error: passwordError,
            obligatory: true,
          ),
          const SizedBox(height: 20),
          FormInput(
            controller: widget.passwordConfirmationController,
            hintText: "dro\$aParole1",
            icon: Icons.lock,
            obscureText: true,
            error: passwordConfirmationError,
            obligatory: true,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _validateAndProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Turpināt',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      bottomAction: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Jau ir konts?",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: () => widget.onViewChange(0),
            child: Text(
              "Ielogoties",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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
