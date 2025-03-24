import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    nameCtrl.text = user!.displayName ?? '';
    emailCtrl.text = user!.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final colors = ColorContext.of(context);

    return Container(
      decoration: colors.classicDecoration,
      width: 350,
      constraints: BoxConstraints(
        maxHeight: height * 0.65,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: SingleChildScrollView(
        child: Column(
          spacing: 15,
          children: [
            button("Atpakaļ", Icons.keyboard_return_rounded, widget.onPressed),
            Divider(color: colors.color003.withAlpha(100)),
            ProfileImage(width: 100),
            TextButton(
              onPressed: () {},
              child: Text(
                "Mainīt profila attēlu",
                style: TextStyle(color: colors.color003),
              ),
            ),
            inputField("Vārds", Icons.person_outline, nameCtrl),
            inputField("E-pasts", Icons.email_outlined, emailCtrl),
            SizedBox(),
            saveButton(),
          ],
        ),
      ),
    );
  }

  Widget inputField(String hint, IconData icon, TextEditingController ctrl) {
    final colors = ColorContext.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: colors.color003),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  bool isObscure = true;

  void toggleObscure() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  Widget saveButton() {
    final colors = ColorContext.of(context);
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 25),
      width: double.infinity,
      child: StylizedButton(
        action: () {},
        title: "Saglabāt izmaiņas",
        icon: Icons.save,
        textStyle: colors.bodyMediumThemeColor,
      ),
    );
  }

  Widget changePasswordButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      child: StylizedButton(
        action: () {},
        title: "Mainīt paroli",
        textStyle: bodySmallRed,
        icon: Icons.password,
      ),
    );
  }

  Widget logout() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      child: StylizedButton(
        action: () {
          FirebaseAuth.instance.signOut();
        },
        title: "Izlogoties",
        textStyle: bodySmallRed,
        icon: Icons.logout,
      ),
    );
  }

  button(
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
