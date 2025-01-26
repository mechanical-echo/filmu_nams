import 'dart:io';
import 'package:filmu_nams/views/auth/registration_steps/registration_state.dart';
import 'package:filmu_nams/views/resources/input/filled_button_icon.dart';
import 'package:filmu_nams/views/resources/input/text_input.dart';
import 'package:filmu_nams/views/resources/services/user_registration.dart';
import 'package:filmu_nams/views/resources/validators/validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class RegistrationSecondStep extends StatefulWidget {
  final VoidCallback previousRegistrationStep;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;

  const RegistrationSecondStep({
    super.key,
    required this.previousRegistrationStep,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
  });

  @override
  State<RegistrationSecondStep> createState() => _RegistrationSecondStepState();
}

class _RegistrationSecondStepState extends State<RegistrationSecondStep> {
  File? _image;
  String? nameError = "";
  Validator validator = Validator();
  bool isLoading = false;

  final _picker = ImagePicker();

  get name => widget.nameController.text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.only(top: 65, bottom: 40),
              child: LoadingAnimationWidget.stretchedDots(
                size: 100,
                color: Theme.of(context).focusColor,
              ),
            )
          : Column(children: [
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
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
                error: nameError,
                obligatory: true,
              ),
              FilledButton(
                onPressed: submit,
                child: Text(
                  "Pabeigt reģistrēšanos",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ]),
    );
  }

  void pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  bool nameValid() {
    setState(() {
      nameError = null;
    });

    ValidatorResult nameValidation = validator.validateName(name);

    if (nameValidation.isNotValid) {
      setState(() {
        nameError = nameValidation.error;
      });
    }

    return nameValidation.isValid;
  }

  void submit() {
    if (!nameValid()) {
      return;
    }

    Provider.of<RegistrationState>(context, listen: false)
        .setRegistrationComplete(false);

    setState(() {
      isLoading = true;
    });

    UserRegistrationService registrationService = UserRegistrationService();

    registrationService
        .registerUser(
      email: widget.emailController.text,
      password: widget.passwordController.text,
      name: widget.nameController.text,
      profileImage: _image,
    )
        .then((user) {
      if (user != null) {
        print('User registered successfully');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          Provider.of<RegistrationState>(context, listen: false)
              .setRegistrationComplete(true);
        }
      } else {
        print('Registration failed');
      }
    });
  }
}
