import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/enums/auth_error_codes.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:filmu_nams/validators/validator.dart';
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  get email => emailController.text;
  get password => passwordController.text;

  String? emailError;
  String? passwordError;

  bool isLoading = false;
  Validator validator = Validator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? Loading()
          : Column(
              children: [
                WelcomeText(),
                LoginInputs(
                  emailController: emailController,
                  passwordController: passwordController,
                  emailError: emailError,
                  passwordError: passwordError,
                ),
                SocialLoginButtons(),
                BottomActions(
                  onViewChange: widget.onViewChange,
                  onSignIn: signIn,
                ),
              ],
            ),
    );
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
      if (mounted) {
        StylizedDialog.alert(
          context,
          "Kļūda",
          getFirebaseAuthErrorCode(e.code),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
}

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 65, bottom: 40),
      child: LoadingAnimationWidget.stretchedDots(
        size: 100,
        color: Theme.of(context).focusColor,
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Text(
        'Laipni lūdzam!',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w300,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class LoginInputs extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;

  const LoginInputs({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.emailError,
    this.passwordError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }
}

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          icon: 'assets/google.png',
          onPressed: () {},
        ),
        _SocialButton(
          icon: 'assets/facebook.png',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 23, horizontal: 6),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 119, 41, 32),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          icon,
          width: 25,
          color: Colors.white,
        ),
        iconSize: 48,
        padding: EdgeInsets.all(12),
      ),
    );
  }
}

class BottomActions extends StatelessWidget {
  final Function(int) onViewChange;
  final VoidCallback onSignIn;

  const BottomActions({
    super.key,
    required this.onViewChange,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
              onPressed: () => onViewChange(1),
              child: Text("Piereģistrēties"),
            )
          ],
        ),
        FilledButton(
          onPressed: onSignIn,
          child: Text(
            "Ielogoties",
          ),
        ),
      ],
    );
  }
}
