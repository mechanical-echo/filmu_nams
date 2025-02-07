import 'package:filmu_nams/views/auth/components/auth_form_container.dart';
import 'package:filmu_nams/views/resources/decorations/background.dart';
import 'package:filmu_nams/views/resources/decorations/big_logo.dart';
import 'package:filmu_nams/views/resources/input/filled_text_icon_button.dart';
import 'package:filmu_nams/views/resources/input/outline_button_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Import Timer class

class EmailNotVerified extends StatefulWidget {
  const EmailNotVerified({super.key});

  @override
  _EmailNotVerifiedState createState() => _EmailNotVerifiedState();
}

class _EmailNotVerifiedState extends State<EmailNotVerified> {
  final user = FirebaseAuth.instance.currentUser; // Define user here
  bool isButtonDisabled = false;
  int timerDuration = 30;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Background(
        child: Column(
          children: [
            BigLogo(top: (height * 0.17)),
            AuthFormContainer(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 40.0,
                  left: 35,
                  right: 35,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Icon(
                            Icons.error_outline,
                            size: 55,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Jūsu e-pasts nav verificēts!",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      "Lūdzu, nospiediet pogu lejā, lai nosūtīt saiti verificēšanai uz Jūsu e-pasta adresi un atgriezieties pēc e-pasta verifikācijas",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      user?.email ?? "",
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                      ),
                    ),
                    Column(
                      children: [
                        FilledTextIconButton(
                          icon: Icons.mark_email_read_outlined,
                          title: "Nosūtīt saiti",
                          onPressed: isButtonDisabled
                              ? () {}
                              : sendVerificationEmail, // Use a lambda function
                          paddingY: 25,
                        ),
                        OutlineButtonIcon(
                          title: "Izlogoties",
                          icon: Icons.logout,
                          onPressed: logout,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  void sendVerificationEmail() async {
    setState(() {
      isButtonDisabled = true;
    });

    await user?.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerDuration > 0) {
        setState(() {
          timerDuration--;
        });
      } else {
        setState(() {
          isButtonDisabled = false;
          timer.cancel();
          timerDuration = 30; // Reset timer
        });
      }
    });
  }
}
