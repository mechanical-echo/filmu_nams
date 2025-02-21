import 'package:bordered_text/bordered_text.dart';
import 'package:filmu_nams/assets/input/filled_icon_button.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Logo extends StatelessWidget {
  Logo({super.key});

  final UserController userController = UserController();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return AppBar(
      titleSpacing: 0,
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      title: Container(
          clipBehavior: Clip.none,
          child: Column(
            children: [
              Container(height: 75), //tukšā vieta virs logotipa

              // Josla ar logotipu
              AppBar(
                clipBehavior: Clip.none,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SvgPicture.asset(
                        "assets/Logo.svg",
                        height: 120,
                      ),
                    ),

                    // Šodienas datums
                    Row(
                      spacing: 20,
                      children: [
                        BorderedText(
                          strokeWidth: 5.0,
                          strokeColor: Colors.black,
                          child: Text(
                            DateFormat('E dd.MM.', 'lv').format(DateTime.now()),
                            style: GoogleFonts.kodchasan(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (kIsWeb && user != null)
                          FutureBuilder<bool>(
                            future: userController.userHasRole(user, "admin"),
                            builder: (context, snapshot) {
                              if (snapshot.data == true) {
                                return FilledIconButton(
                                  onPressed: () {
                                    FirebaseAuth.instance.signOut();
                                  },
                                  icon: Icons.logout,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                centerTitle: false,
              )
            ],
          )),
    );
  }
}
