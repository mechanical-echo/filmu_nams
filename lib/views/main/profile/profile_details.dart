import 'package:filmu_nams/views/resources/decorations/background.dart';
import 'package:filmu_nams/views/resources/decorations/profile_image.dart';
import 'package:filmu_nams/views/resources/dialog/dialog.dart';
import 'package:filmu_nams/views/resources/enums/auth_error_codes.dart';
import 'package:filmu_nams/views/resources/input/filled_icon_button.dart';
import 'package:filmu_nams/views/resources/input/text_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordConfirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? '';
    emailController.text = user?.email ?? '';
  }

  Future<void> updateName() async {
    if (nameController.text.trim().isEmpty) {
      StylizedDialog.alert(
        context,
        "Kļūda",
        "Vārds nevar būt tukšs",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await user?.updateDisplayName(nameController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'name': nameController.text.trim(),
      });

      if (mounted) {
        StylizedDialog.alert(
          context,
          "Veiksmīgi",
          "Vārds ir atjaunināts",
        );
      }
    } catch (e) {
      if (mounted) {
        StylizedDialog.alert(
          context,
          "Kļūda",
          "Neizdevās atjaunināt vārdu",
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateEmail() async {
    if (emailController.text.trim().isEmpty) {
      StylizedDialog.alert(
        context,
        "Kļūda",
        "E-pasts nevar būt tukšs",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await user?.verifyBeforeUpdateEmail(emailController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'email': emailController.text.trim(),
      });

      if (mounted) {
        StylizedDialog.alert(
          context,
          "Veiksmīgi",
          "Lūdzu pārbaudiet savu e-pastu, lai apstiprinātu izmaiņas",
        );
      }
    } catch (e) {
      if (mounted) {
        StylizedDialog.alert(
          context,
          "Kļūda",
          e.toString(),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updatePassword() async {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        newPasswordConfirmationController.text.isEmpty) {
      StylizedDialog.alert(
        context,
        "Kļūda",
        "Visiem paroles laukiem jābūt aizpildītiem",
      );
      return;
    }

    if (newPasswordController.text != newPasswordConfirmationController.text) {
      StylizedDialog.alert(
        context,
        "Kļūda",
        "Jaunās paroles nesakrīt",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPasswordController.text,
      );

      await user?.reauthenticateWithCredential(credential);
      await user?.updatePassword(newPasswordController.text);

      oldPasswordController.clear();
      newPasswordController.clear();
      newPasswordConfirmationController.clear();

      if (mounted) {
        StylizedDialog.alert(
          context,
          "Veiksmīgi",
          "Parole ir atjaunināta",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        StylizedDialog.alert(
          context,
          "Kļūda",
          getFirebaseAuthErrorCode(e.code),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.stretchedDots(
          size: 100,
          color: Theme.of(context).focusColor,
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final textFieldWidth = width * 0.82;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Profila detaļas',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Background(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 38.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProfileImage(
                        width: 130,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user!.displayName ?? 'Vārds Uzvārds',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Reģistrēts:',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            DateFormat(
                                    '${DateFormat.DAY}.${DateFormat.NUM_MONTH}.${DateFormat.YEAR} ${DateFormat.HOUR24}:${DateFormat.MINUTE}',
                                    'lv')
                                .format(user!.metadata.creationTime ??
                                    DateTime.now()),
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: nameController,
                        labelText: "Vārds",
                        hintText: "Ievadiet vārdu",
                        icon: Icon(Icons.person),
                        obscureText: false,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    FilledIconButton(onPressed: updateName, icon: Icons.save)
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: emailController,
                        labelText: "E-pasts",
                        hintText: "Ievadiet e-pastu",
                        icon: Icon(Icons.email),
                        obscureText: false,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    FilledIconButton(onPressed: updateEmail, icon: Icons.save)
                  ],
                ),
                Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: oldPasswordController,
                        labelText: "Vecā parole",
                        hintText: "Ievadiet paroli",
                        obscureText: true,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    SizedBox(
                      width: textFieldWidth,
                      child: TextInput(
                        controller: newPasswordController,
                        labelText: "Jauna parole",
                        hintText: "Ievadiet paroli",
                        obscureText: true,
                        margin: [20, 20, 20, 20],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: textFieldWidth,
                          child: TextInput(
                            controller: newPasswordConfirmationController,
                            labelText: "Jaunā parole atkārtoti",
                            hintText: "Ievadiet paroli",
                            icon: Icon(Icons.email),
                            obscureText: true,
                            margin: [20, 20, 20, 20],
                          ),
                        ),
                        FilledIconButton(
                            onPressed: updatePassword, icon: Icons.save)
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
