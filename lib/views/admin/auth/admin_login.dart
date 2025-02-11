import 'package:filmu_nams/views/client/auth/components/auth_form_container.dart';
import 'package:filmu_nams/assets/input/filled_text_icon_button.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextEditingController usernameController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      Column(
        spacing: 30,
        children: [
          WelcomeText(),
          LoginForm(),
        ],
      ),
    );
  }

  Widget Wrapper(Widget child) {
    return SizedBox(
      width: 750,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AuthFormContainer(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 60.0,
                left: 40,
                right: 40,
              ),
              child: child,
            ),
          )
        ],
      ),
    );
  }

  Widget WelcomeText() {
    return Text(
      "Laipni lūdzam\n administrācijas panelī",
      textAlign: TextAlign.center,
      style: GoogleFonts.roboto(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 34,
      ),
    );
  }

  Widget LoginForm() {
    return SizedBox(
      width: 500,
      child: Column(
        spacing: 20,
        children: [
          TextInput(
            controller: usernameController,
            labelText: "E-pasts",
            hintText: "Ievadiet e-pastu...",
          ),
          TextInput(
            controller: passwordController,
            labelText: "Parole",
            hintText: "Ievadiet paroli...",
            obscureText: true,
          ),
          FilledTextIconButton(
            icon: Icons.login,
            title: "Ielogoties",
            onPressed: () {},
            paddingY: 20,
          ),
        ],
      ),
    );
  }
}
