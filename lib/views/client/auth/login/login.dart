import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/enums/auth_error_codes.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:filmu_nams/validators/validator.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    ValidatorResult emailValidation = validator.validateEmail(email, true);
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
      child: LoadingAnimationWidget.staggeredDotsWave(
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
      margin: const EdgeInsets.only(top: 25, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: classicDecorationWhiteSharper,
      child: Text(
        'Laipni lūdzam!',
        style: header1Red,
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

class SocialLoginButtons extends StatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  void google() async {
    final response = await UserController().signInWithGoogle();
    if (response == null && mounted) {
      StylizedDialog.alert(
          context, "Kļūda", "Notikusi kļūda, meģinot ielogoties ar Google");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        socialButton(
          'assets/google.png',
          () => google(),
        ),
        socialButton(
          'assets/facebook.png',
          () {},
        ),
      ],
    );
  }

  socialButton(String icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 23, horizontal: 7),
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: classicDecorationWhiteSharper,
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          icon,
          width: 25,
          color: red001,
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
              style: bodyMedium,
            ),
            TextButton(
              onPressed: () => onViewChange(1),
              child: Text("Piereģistrēties"),
            )
          ],
        ),
        IntrinsicWidth(
          child: StylizedButton(
            action: onSignIn,
            title: "Ielogoties",
            icon: Icons.login,
          ),
        ),
      ],
    );
  }
}
