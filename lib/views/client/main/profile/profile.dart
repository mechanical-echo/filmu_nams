import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
import 'package:filmu_nams/views/client/main/profile/profile_view.dart';
import 'package:filmu_nams/views/client/main/profile/settings.dart';
import 'package:filmu_nams/views/client/main/profile/tickets/tickets_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;
  int currentView = 0;
  CarouselSwitchDirection direction = CarouselSwitchDirection.left;

  void switchView(int viewIndex) {
    setState(() {
      direction = viewIndex == 0
          ? CarouselSwitchDirection.right
          : CarouselSwitchDirection.left;
      currentView = viewIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      profileMenu(context),
      ProfileView(onPressed: () => switchView(0)),
    ];

    return Center(
      child: CarouselSwitch(
        alignment: AlignmentDirectional.center,
        direction: direction,
        child: KeyedSubtree(
          key: ValueKey(currentView),
          child: views[currentView],
        ),
      ),
    );
  }

  Widget profileMenu(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProfileImage(width: 100),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  user!.displayName!,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
          const SizedBox(height: 30),
          _buildMenuButton(
            "Profils",
            Icons.person_outline,
            () => switchView(1),
          ),
          _buildMenuButton(
            "Biļetes",
            Icons.confirmation_number_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketsView()),
              );
            },
          ),
          _buildMenuButton(
            "Maksājumi",
            Icons.payment_outlined,
            () {},
          ),
          _buildMenuButton(
            "Iestatījumi",
            Icons.settings_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
