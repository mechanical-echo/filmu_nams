import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
import 'package:filmu_nams/views/client/main/profile/profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;

  List<Widget> views = [];

  @override
  void initState() {
    super.initState();
    views = [
      profileMenu(),
      ProfileView(onPressed: () => switchView(0)),
    ];
  }

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
    return Center(
      child: CarouselSwitch(
        direction: direction,
        child: KeyedSubtree(
          key: ValueKey(currentView),
          child: views[currentView],
        ),
      ),
    );
  }

  Container profileMenu() {
    return Container(
      decoration: classicDecoration,
      width: 350,
      height: 420,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(
        children: [
          Row(
            spacing: 15,
            children: [
              ProfileImage(width: 120),
              Expanded(
                child: Text(
                  user!.displayName!,
                  style: header2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          ...divider(),
          button("Profils", Icons.person, () => switchView(1)),
          button("Biļetes", Icons.payments_sharp, () {}),
          button("Maksājumi", Icons.payment, () {}),
          button("Iestatījumi", Icons.settings, () {}),
        ],
      ),
    );
  }

  divider() {
    return [
      SizedBox(height: 25),
      Divider(color: red003.withAlpha(100)),
      SizedBox(height: 25)
    ];
  }

  button(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          fixedSize: Size(500, 30),
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Icon(icon, size: 25),
            SizedBox(width: 500, child: Text(title)),
          ],
        ),
      ),
    );
  }
}
