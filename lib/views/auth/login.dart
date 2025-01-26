import 'package:filmu_nams/views/resources/dialog/dialog.dart';
import 'package:filmu_nams/views/resources/input/text_input.dart';
import 'package:filmu_nams/views/resources/validators/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Login extends StatefulWidget {
  final Function(int) onViewChange;

  const Login({super.key, required this.onViewChange});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  Validator validator = Validator();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  get email => emailController.text;
  get password => passwordController.text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.only(top: 65, bottom: 40),
              child: LoadingAnimationWidget.stretchedDots(
                size: 100,
                color: Theme.of(context).focusColor,
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: Text(
                    'Laipni lūdzam!',
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
                  controller: emailController,
                  obligatory: true,
                  error: emailError,
                ),
                TextInput(
                  obscureText: true,
                  labelText: "Parole",
                  hintText: "dro\$aParole1",
                  margin: [0, 35, 0, 35],
                  controller: passwordController,
                  obligatory: true,
                  error: passwordError,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 23, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 119, 41, 32),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/google.png',
                          width: 25,
                          color: Colors.white,
                        ),
                        iconSize: 48,
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 23, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 119, 41, 32),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/facebook.png',
                          width: 25,
                          color: Colors.white,
                        ),
                        iconSize: 48,
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Nav konta?",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 167, 167, 167),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.onViewChange(1),
                          child: Text("Piereģistrēties"),
                        )
                      ],
                    ),
                    FilledButton(
                      onPressed: signIn,
                      child: Text(
                        "Ielogoties",
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  bool areFieldsValid() {
    emailError = passwordError = null;

    ValidatorResult emailValidation = validator.validateEmail(email);
    ValidatorResult emptyFieldsValidation = validator.checkEmptyFields({
      "email": email,
      "password": password,
    });

    bool isValid = true;

    if (emailValidation.isNotValid) {
      setState(() {
        emailError = emailValidation.error;
      });
      isValid = false;
    }

    if (emptyFieldsValidation.isNotValid) {
      for (var field in emptyFieldsValidation.problematicFields) {
        switch (field) {
          case "email":
            setState(() {
              emailError = emptyFieldsValidation.error;
            });

            break;
          case "password":
            setState(() {
              passwordError = emptyFieldsValidation.error;
            });
            break;
        }
      }

      isValid = false;
    }

    return isValid;
  }

  void signIn() async {
    if (!areFieldsValid()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case "user-not-found":
        case "invalid-credential":
        case "wrong-password":
          message = "Nepareizs epasts vai parole";
          break;
        default:
          message = e.code;
      }

      if (mounted) {
        StylizedDialog.alert(
          context,
          "Kļūda",
          message,
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
