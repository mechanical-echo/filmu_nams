import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:filmu_nams/views/client/main/profile/profile_view.dart';
import 'package:filmu_nams/views/client/main/profile/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    final colors = ColorContext.of(context);

    return IntrinsicHeight(
      child: Container(
        decoration: colors.classicDecoration,
        width: 350,
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
                    style: colors.bodyLargeFor(colors.color002),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            ...divider(colors),
            button("Profils", Icons.person, () => switchView(1)),
            button("Biļetes", Icons.payments_sharp, () {}),
            button("Maksājumi", Icons.payment, () {}),
            button("Iestatījumi", Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Widget> divider(ColorContext colors) {
    return [
      const SizedBox(height: 25),
      Divider(color: colors.color003.withAlpha(100)),
      const SizedBox(height: 25)
    ];
  }

  Widget button(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: StylizedButton(
        action: onPressed,
        title: title,
        icon: icon,
      ),
    );
  }
}
