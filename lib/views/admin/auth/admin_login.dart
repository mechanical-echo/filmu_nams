import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/controllers/login_controller.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/views/client/auth/login/login_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  get theme => Theme.of(context);

  String? emailError;
  String? passwordError;

  bool isLoading = false;
  bool isPasswordVisible = false;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 50,
          children: [
            buildWelcomeText(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
              margin: const EdgeInsets.symmetric(horizontal: 35),
              constraints: BoxConstraints(maxWidth: 500),
              decoration: theme.cardDecoration,
              child: Form(
                key: formKey,
                child: Column(
                  spacing: 20,
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: LoginValidator.validateEmail,
                      decoration: InputDecoration(
                        hintText: "Ievadiet e-pastu",
                        label: Text('E-pasts'),
                        prefixIcon: Icon(
                          Icons.email,
                          color: theme.contrast.withAlpha(100),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      validator: LoginValidator.validatePassword,
                      decoration: InputDecoration(
                        hintText: "Ievadiet paroli",
                        label: Text('Parole'),
                        prefixIcon: Icon(
                          Icons.password,
                          color: theme.contrast.withAlpha(100),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.contrast.withAlpha(100),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: FilledButton(
                        onPressed: login,
                        child: isLoading
                            ? LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.white, size: 30)
                            : Stack(
                                alignment: Alignment.centerLeft,
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: -18,
                                    child: Icon(Icons.login),
                                  ),
                                  Center(
                                    child: Text("Ielogoties"),
                                  )
                                ],
                              ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildWelcomeText() {
    return Center(
        child: Column(
      children: [
        Text(
          "Laipni lūdzam",
          style: theme.displayLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          "Filmu Nams",
          style: GoogleFonts.poppins(
            color: theme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 48,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "adminsitrācijas panelī",
          style: theme.displayLarge,
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }

  void login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool userIsAdmin =
            await UserController().userHasRole(user.uid, "admin");

        setState(() {
          isLoading = false;
        });

        if (!userIsAdmin) {
          await FirebaseAuth.instance.signOut();
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Error signing in as Admin: ${e.toString()}");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        StylizedDialog.dialog(
          Icons.error_outline,
          context,
          "Kļūda",
          LoginController().getMessage(e.code),
        );
      }
    }
  }
}
