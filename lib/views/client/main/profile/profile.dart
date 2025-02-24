import 'package:filmu_nams/assets/animations/animated_routing.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
import 'package:filmu_nams/assets/input/filled_text_icon_button.dart';
import 'package:filmu_nams/views/client/main/profile/profile_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      children: [
        ProfileContainer(
          children: [
            ProfileImage(width: 85),
            Username(),
            ProfileSubPages(),
          ],
        ),
        LogoutButton(),
      ],
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class Username extends StatelessWidget {
  Username({super.key});
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Text(
        user!.displayName!,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}

class ProfileSubPages extends StatelessWidget {
  const ProfileSubPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledTextIconButton(
      icon: Icons.logout,
      title: "Izlogoties",
      onPressed: logOut,
      paddingY: 20,
    );
  }

  void logOut() {
    FirebaseAuth.instance.signOut();
  }
}
