import 'dart:io';

import 'package:filmu_nams/views/resources/input/filled_button_icon.dart';
import 'package:filmu_nams/views/resources/input/text_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationSecondStep extends StatefulWidget {
  final TextEditingController nameController;
  final VoidCallback previousRegistrationStep;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;

  const RegistrationSecondStep({
    super.key,
    required this.nameController,
    required this.previousRegistrationStep,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
  });

  @override
  State<RegistrationSecondStep> createState() => _RegistrationSecondStepState();
}

class _RegistrationSecondStepState extends State<RegistrationSecondStep> {
  File? _image;

  final _picker = ImagePicker();

  void pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        FilledButtonIcon(
          icon: Icons.keyboard_return,
          title: "Atpakaļ",
          onPressed: widget.previousRegistrationStep,
          padding_y: 25,
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Text(
            'Prieks iepazīsties!',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
          child: _image == null
              ? Text(
                  "Jūs varat izvēlēties bildi savām kontam  (nav obligāti)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              : Container(
                  width: 100,
                  height: 100,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        TextButton(
          onPressed: pickImage,
          child: Text("Izvēlēties bildi"),
        ),
        TextInput(
          obscureText: false,
          labelText: "Vārds",
          hintText: "Jānis Bērziņš",
          icon: Icon(Icons.person),
          margin: [0, 35, 25, 35],
          controller: widget.nameController,
        ),
        FilledButton(
          onPressed: () {},
          child: Text(
            "Pabeigt reģistrēšanos",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ]),
    );
  }
}
