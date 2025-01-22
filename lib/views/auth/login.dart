import 'package:filmu_nams/views/resources/background.dart';
import 'package:filmu_nams/views/resources/big_logo.dart';
import 'package:filmu_nams/views/resources/text_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    void signIn() async {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    }

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            BigLogo(
              top: 164,
            ),
            Container(
              margin: const EdgeInsets.only(top: 100, right: 25, left: 25),
              width: width,
              height: 475,
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(children: [
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
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text("Piereġistrēties"),
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
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
