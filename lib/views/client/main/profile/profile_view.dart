import 'package:filmu_nams/assets/theme.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
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
    return Container(
      decoration: classicDecoration,
      width: 350,
      height: 600,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(
        spacing: 15,
        children: [
          button("Atpakaļ", Icons.keyboard_return_rounded, widget.onPressed),
          Divider(color: red003.withAlpha(100)),
          ProfileImage(width: 100),
          TextButton(
            onPressed: () {},
            child: Text(
              "Mainīt profila attēlu",
              style: TextStyle(color: red003),
            ),
          ),
          inputField("Vārds", Icons.person_outline, nameCtrl),
          inputField("E-pasts", Icons.email_outlined, emailCtrl),
          // passwordField("Parole", Icons.lock_outline, passwordCtrl),
          SizedBox(height: 10),
          changePasswordButton(),
          saveButton(),
        ],
      ),
    );
  }

  Widget inputField(String hint, IconData icon, TextEditingController ctrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: red003),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  bool isObscure = true;

  void toggleObscure() {
    debugPrint("rererer");
    setState(() {
      isObscure = !isObscure;
    });
  }

  Widget passwordField(String hint, IconData icon, TextEditingController ctrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: ctrl,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: red003,
            ),
            onPressed: toggleObscure,
          ),
          prefixIcon: Icon(icon, color: red003),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          "Saglabāt izmaiņas",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget changePasswordButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: red001,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(vertical: 0),
          fixedSize: Size(500, 10),
        ),
        child: Text(
          "Mainīt paroli",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
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
