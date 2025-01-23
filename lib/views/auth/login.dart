import 'package:filmu_nams/views/resources/text_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
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
          message = "Lietotājs nav atrasts";
          break;
        case "wrong-password":
          message = "Nepareizs epasts vai parole";
          break;
        default:
          message = e.code;
      }

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text("Kļūda"),
          content: Text(message),
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? LoadingAnimationWidget.stretchedDots(
              size: 100,
              color: Theme.of(context).focusColor,
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
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
                ),
                TextInput(
                  obscureText: true,
                  labelText: "Parole",
                  hintText: "dro\$aParole1",
                  margin: [0, 35, 0, 35],
                  controller: passwordController,
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
}
