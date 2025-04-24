import 'dart:io';

import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../providers/theme.dart';

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
  ImagePicker picker = ImagePicker();

  UserController userController = UserController();
  User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = false;
  File? image;

  @override
  void initState() {
    super.initState();
    nameCtrl.text = user!.displayName ?? '';
    emailCtrl.text = user!.email ?? '';
  }

  void submit() async {
    setState(() {
      isLoading = true;
    });

    try {
      await user!.updateDisplayName(nameCtrl.text);
      if (emailCtrl.text != user!.email) {
        await user?.verifyBeforeUpdateEmail(emailCtrl.text);
      }
      await userController.updateOwnProfile(
          name: nameCtrl.text, email: emailCtrl.text, profileImage: image);
    } catch (e) {
      if (mounted) {
        StylizedDialog.dialog(
            Icons.error_outline, context, "Kļūda", "Neizdevās atjaunināt");
        debugPrint(e.toString());
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final theme = Style.of(context);

    return Container(
      width: 350,
      constraints: BoxConstraints(
        maxHeight: height * 0.65,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: theme.cardDecoration,
      child: isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 50,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackButton(),
                      Container(
                        decoration: theme.cardDecoration,
                        child: Icon(
                          Icons.person,
                          size: 45,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                  _buildProfileImage(),
                  _buildInputFields(),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildBackButton() {
    final theme = Style.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: theme.cardDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              Text(
                "Atpakaļ",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final theme = Style.of(context);
    return Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.max,
      children: [
        ProfileImage(
          width: 120,
          customImage: image,
        ),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      user!.displayName!.replaceFirst(' ', '\n'),
                      style: theme.displaySmall,
                    ),
                  ),
                  InkWell(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 13,
                      ),
                      decoration: theme.cardDecoration,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          Center(
                            child: Text(
                              "Mainīt bildi",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      spacing: 10,
      children: [
        _buildInputField("Vārds", Icons.person_outline, nameCtrl),
        _buildInputField("E-pasts", Icons.email_outlined, emailCtrl),
      ],
    );
  }

  Widget _buildInputField(
    String hint,
    IconData icon,
    TextEditingController ctrl,
  ) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final theme = Style.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: submit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: theme.activeCardDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(
                Icons.save_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              Text(
                "Saglabāt izmaiņas",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
