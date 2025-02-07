import 'package:filmu_nams/views/main/profile/profile_details.dart';
import 'package:filmu_nams/views/resources/animations/animated_routing.dart';
import 'package:filmu_nams/views/resources/decorations/profile_image.dart';
import 'package:filmu_nams/views/resources/input/filled_text_icon_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // atstarpe
          SizedBox(
            height: 100,
          ),

          // fons
          Container(
            height: 400,
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // lietotāja bilde
                ProfileImage(width: 85),

                // Lietotāja vārds
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    user!.displayName!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),

                // Profila zemsadaļas
                FilledTextIconButton(
                  onPressed: () {},
                  icon: Icons.credit_card,
                  title: "Maksājumi",
                  paddingY: 5,
                ),
                FilledTextIconButton(
                  onPressed: () {},
                  icon: Icons.payments_outlined,
                  title: "Biļetes",
                  paddingY: 5,
                ),
                FilledTextIconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      AnimatedRouting(page: ProfileDetails()),
                    );
                  },
                  icon: Icons.info_outlined,
                  title: "Profila info",
                  paddingY: 5,
                ),
              ],
            ),
          ),

          // Izlogošana
          FilledTextIconButton(
            icon: Icons.logout,
            title: "Izlogoties",
            onPressed: logOut,
            paddingY: 20,
          ),
        ],
      ),
    );
  }
}
