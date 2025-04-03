import 'dart:io';

import 'package:filmu_nams/assets/dialog/dialog.dart';
import 'package:filmu_nams/assets/widgets/profile_image.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      await user?.verifyBeforeUpdateEmail(emailCtrl.text);
      await userController.updateOwnProfile(
          nameCtrl.text, emailCtrl.text, image);
    } catch (e) {
      if (mounted) {
        StylizedDialog.alert(context, "Kļūda", "Neizdevās atjaunināt");
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

    return Container(
      width: 350,
      constraints: BoxConstraints(
        maxHeight: height * 0.65,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 50,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 20),
                  _buildProfileImage(),
                  const SizedBox(height: 20),
                  _buildInputFields(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
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
    return Column(
      children: [
        ProfileImage(
          width: 120,
          customImage: image,
        ),
        const SizedBox(height: 15),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Mainīt profila attēlu",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildInputField("Vārds", Icons.person_outline, nameCtrl),
        const SizedBox(height: 15),
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
        hintStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: submit,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.save_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
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
