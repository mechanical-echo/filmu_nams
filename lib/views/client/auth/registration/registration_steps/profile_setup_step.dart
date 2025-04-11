import 'dart:io';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/client/auth/registration/registration_steps/registration_state.dart';
import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/enums/auth_error_codes.dart';
import 'package:filmu_nams/assets/components/form_input.dart';
import 'package:filmu_nams/assets/components/auth_container.dart';
import 'package:filmu_nams/assets/components/loading_indicator.dart';
import 'package:filmu_nams/validators/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
    return AuthContainer(
      title: 'Reģistrācija',
      child: _isLoading
          ? const Center(child: LoadingIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Profila iestatīšana',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _ProfileImagePicker(
                  image: _image,
                  onPickImage: _pickImage,
                ),
                const SizedBox(height: 20),
                FormInput(
                  controller: widget.nameController,
                  hintText: "Jūsu vārds",
                  icon: Icons.person,
                  error: nameError,
                  obligatory: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Pabeigt reģistrāciju',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
      bottomAction: TextButton(
        onPressed: widget.previousRegistrationStep,
        child: Text(
          'Atpakaļ',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        StylizedDialog.dialog(Icons.error_outline,
          context,
          "Kļūda",
          getFirebaseAuthErrorCode(response?.errorMessage),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      StylizedDialog.dialog(Icons.error_outline,context, "Kļūda", "Nezināma kļūda");
    }
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
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: image == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white.withOpacity(0.5),
                  )
                : Image.file(
                    image!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 15),
        TextButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.add_a_photo, color: Colors.white),
          label: Text(
            'Izvēlēties bildi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
