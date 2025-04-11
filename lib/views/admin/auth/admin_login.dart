import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/enums/auth_error_codes.dart';
import 'package:filmu_nams/validators/validator.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  get email => emailController.text;
  get password => passwordController.text;

  Validator validator = Validator();

  String? emailError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: AnimatedSize(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: IntrinsicHeight(
              child: Container(
                decoration: classicDecorationDark,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                child: IntrinsicWidth(
                  child: Row(
                    spacing: 30,
                    children: [
                      buildWelcomeText(),
                      buildLoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildWelcomeText() {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
        ),
        decoration: classicDecorationWhiteSharper,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Center(
          child: Text(
            "Laipni lūdzam administrācijas panelī",
            textAlign: TextAlign.center,
            style: header1Red,
          ),
        ),
      ),
    );
  }

  Widget buildLoginForm() {
    return Expanded(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  Icon(Icons.email, size: 25, color: smokeyWhite),
                  Text("E-pasts", style: bodyMedium),
                ],
              ),
              SizedBox(
                width: 500,
                child: TextInput(
                  controller: emailController,
                  error: emailError,
                  obligatory: true,
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  Icon(Icons.password, size: 25, color: smokeyWhite),
                  Text("Parole", style: bodyMedium),
                ],
              ),
              SizedBox(
                width: 500,
                child: TextInput(
                  controller: passwordController,
                  obscureText: true,
                  error: passwordError,
                  obligatory: true,
                ),
              ),
              SizedBox(height: 75),
            ],
          ),
          SizedBox(
            width: 500,
            child: IntrinsicHeight(
              child: StylizedButton(
                icon: Icons.login,
                title: "Ielogoties",
                action: login,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void login() async {
    if (!isValid()) {
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool userIsAdmin = await UserController().userHasRole(user, "admin");

        if (!userIsAdmin) {
          await FirebaseAuth.instance.signOut();
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Error signing in as Admin: ${e.toString()}");
      if (mounted) {
        StylizedDialog.dialog(Icons.error_outline,
          context,
          "Kļūda",
          getFirebaseAuthErrorCode(e.code)
        );
      }
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
