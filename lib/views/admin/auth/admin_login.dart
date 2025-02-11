import 'package:filmu_nams/validators/validator.dart';
import 'package:filmu_nams/views/client/auth/components/auth_form_container.dart';
import 'package:filmu_nams/assets/input/filled_text_icon_button.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Column(
        spacing: 30,
        children: [
          WelcomeText(),
          LoginForm(),
        ],
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 750,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AuthFormContainer(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 60.0,
                left: 40,
                right: 40,
              ),
              child: child,
            ),
          )
        ],
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Laipni lūdzam\n administrācijas panelī",
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 34,
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  get email => emailController.text;
  get password => passwordController.text;

  Validator validator = Validator();

  String? emailError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        spacing: 20,
        children: [
          TextInput(
            controller: emailController,
            labelText: "E-pasts",
            hintText: "Ievadiet e-pastu...",
            error: emailError,
            obligatory: true,
          ),
          TextInput(
            controller: passwordController,
            labelText: "Parole",
            hintText: "Ievadiet paroli...",
            obscureText: true,
            error: passwordError,
            obligatory: true,
          ),
          FilledTextIconButton(
            icon: Icons.login,
            title: "Ielogoties",
            onPressed: login,
            paddingY: 20,
          ),
        ],
      ),
    );
  }

  void login() {
    if (!isValid()) {
      return;
    }
  }

  bool isValid() {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    ValidatorResult emailValidationResult =
        validator.validateEmail(email, true);

    if (emailValidationResult.isValid) {
      return true;
    } else {
      setState(() {
        emailError = emailValidationResult.error;
        passwordError = password.isEmpty ? "Lūdzu, ievadiet paroli" : null;
      });
      return false;
    }
  }
}
