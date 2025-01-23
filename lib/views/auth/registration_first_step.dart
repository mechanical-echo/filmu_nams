import 'package:filmu_nams/views/resources/text_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationFirstStep extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final Function(int) onViewChange;
  final VoidCallback nextRegistrationStep;
  const RegistrationFirstStep({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.onViewChange,
    required this.nextRegistrationStep,
  });

  @override
  State<RegistrationFirstStep> createState() => _RegistrationFirstStepState();
}

class _RegistrationFirstStepState extends State<RegistrationFirstStep> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: Text(
            'Prieks iepazīsties!',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none),
          ),
        ),
        TextInput(
          obscureText: false,
          labelText: "E-pasts",
          hintText: "epasts@epasts.lv",
          icon: Icon(Icons.email),
          margin: [25, 35, 25, 35],
          controller: widget.emailController,
        ),
        TextInput(
          obscureText: true,
          labelText: "Parole",
          hintText: "dro\$aParole1",
          margin: [0, 35, 25, 35],
          controller: widget.passwordController,
        ),
        TextInput(
          obscureText: true,
          labelText: "Parole atkārtoti",
          hintText: "dro\$aParole1",
          margin: [0, 35, 0, 35],
          controller: widget.passwordConfirmationController,
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Ir konts?",
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 167, 167, 167),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                TextButton(
                  onPressed: () => {widget.onViewChange(0)},
                  child: Text("Ielogoties"),
                )
              ],
            ),
            FilledButton(
              onPressed: widget.nextRegistrationStep,
              child: Text(
                "Reġistrēties",
              ),
            ),
          ],
        )
      ]),
    );
  }
}
