import 'dart:io';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:filmu_nams/views/client/auth/registration/registration_steps/registration_state.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/enums/auth_error_codes.dart';
import 'package:filmu_nams/assets/input/text_input.dart';
import 'package:filmu_nams/validators/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ProfileSetupStep extends StatefulWidget {
  final VoidCallback previousRegistrationStep;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;

  const ProfileSetupStep({
    super.key,
    required this.previousRegistrationStep,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmationController,
  });

  @override
  State<ProfileSetupStep> createState() => _ProfileSetupStepState();
}

class _ProfileSetupStepState extends State<ProfileSetupStep> {
  File? _image;
  String? nameError;
  bool _isLoading = false;

  final _picker = ImagePicker();
  final _validator = Validator();
  final _userController = UserController();

  String get name => widget.nameController.text;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: _LoadingIndicator());
    }

    return Center(
      child: Column(
        children: [
          _NavigationButton(onPressed: widget.previousRegistrationStep),
          const _StepTitle(),
          _ProfileImagePicker(
            image: _image,
            onPickImage: _pickImage,
          ),
          _NameInput(
            controller: widget.nameController,
            error: nameError,
          ),
          _SubmitButton(onSubmit: _submitProfile),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  bool _validateName() {
    setState(() => nameError = null);
    final validation = _validator.validateName(name);
    if (validation.isNotValid) {
      setState(() => nameError = validation.error);
      return false;
    }
    return true;
  }

  Future<void> _submitProfile() async {
    if (!_validateName()) return;

    Provider.of<RegistrationState>(context, listen: false)
        .setRegistrationComplete(false);

    setState(() => _isLoading = true);

    try {
      final response = await _userController.registerUser(
        email: widget.emailController.text,
        password: widget.passwordController.text,
        name: widget.nameController.text,
        profileImage: _image,
      );

      if (!mounted) return;

      if (response?.user != null) {
        setState(() => _isLoading = false);
        Provider.of<RegistrationState>(context, listen: false)
            .setRegistrationComplete(true);
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.emailController.text,
          password: widget.passwordController.text,
        );
      } else {
        setState(() => _isLoading = false);
        StylizedDialog.alert(
          context,
          "Kļūda",
          getFirebaseAuthErrorCode(response?.errorMessage),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      StylizedDialog.alert(context, "Kļūda", "Nezināma kļūda");
    }
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 65, bottom: 40),
      child: LoadingAnimationWidget.staggeredDotsWave(
        size: 100,
        color: Theme.of(context).focusColor,
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NavigationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: IntrinsicWidth(
        child: StylizedButton(
          icon: Icons.keyboard_return,
          title: "Atpakaļ",
          action: onPressed,
        ),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        'Prieks iepazīties!',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w300,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _ProfileImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onPickImage;

  const _ProfileImagePicker({
    required this.image,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
          child: image == null
              ? const Text(
                  "Jūs varat izvēlēties bildi savām kontam (nav obligāti)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                )
              : Container(
                  width: 100,
                  height: 100,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        TextButton(
          onPressed: onPickImage,
          child: const Text("Izvēlēties bildi"),
        ),
      ],
    );
  }
}

class _NameInput extends StatelessWidget {
  final TextEditingController controller;
  final String? error;

  const _NameInput({
    required this.controller,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);
    return TextInput(
      obscureText: false,
      hintText: "Jānis Bērziņš",
      icon: Icon(Icons.person, color: colors.color001),
      margin: const [25, 35, 25, 35],
      controller: controller,
      error: error,
      obligatory: true,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const _SubmitButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onSubmit,
      child: const Text("Pabeigt reģistrāciju"),
    );
  }
}
