import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:filmu_nams/views/client/auth/components/auth_form_container.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/decorations/big_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class EmailNotVerified extends StatefulWidget {
  const EmailNotVerified({super.key});

  @override
  _EmailNotVerifiedState createState() => _EmailNotVerifiedState();
}

class _EmailNotVerifiedState extends State<EmailNotVerified> {
  final user = FirebaseAuth.instance.currentUser;
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
    final colors = ColorContext.of(context);
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
                  spacing: 20,
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
                            style: colors.bodyLargeThemeColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Lūdzu, nospiediet pogu lejā, lai nosūtīt saiti verificēšanai uz Jūsu e-pasta adresi un atgriezieties pēc e-pasta verifikācijas",
                      style: colors.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      decoration: colors.classicDecorationWhiteSharper,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 5,
                      ),
                      child: Text(
                        user?.email ?? "",
                        style: colors.bodySmall,
                      ),
                    ),
                    Column(
                      spacing: 10,
                      children: [
                        StylizedButton(
                          icon: Icons.mark_email_read_outlined,
                          title: "Nosūtīt saiti",
                          action:
                              isButtonDisabled ? () {} : sendVerificationEmail,
                        ),
                        StylizedButton(
                          title: "Izlogoties",
                          icon: Icons.logout,
                          action: logout,
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
          timerDuration = 30;
        });
      }
    });
  }
}
