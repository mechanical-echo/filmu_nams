import 'package:filmu_nams/views/resources/background.dart';
import 'package:filmu_nams/views/resources/big_logo.dart';
import 'package:filmu_nams/views/resources/text_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final passwordConfirmationController = TextEditingController();

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
                    'Prieks iepazīsties!',
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
                  margin: [0, 35, 25, 35],
                  controller: passwordController,
                ),
                TextInput(
                  obscureText: true,
                  labelText: "Parole atkārtoti",
                  hintText: "dro\$aParole1",
                  margin: [0, 35, 0, 35],
                  controller: passwordConfirmationController,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Ir konts?",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 167, 167, 167),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text("Ielogoties"),
                        )
                      ],
                    ),
                    FilledButton(
                      onPressed: () {},
                      child: Text(
                        "Reġistrēties",
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
